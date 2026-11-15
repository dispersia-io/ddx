const { execFileSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const { EnvironmentError, SemVerError, isSemVer } = require('../../utils/env.js');

const { ROOT_DIR, NODE_VERSION, NODE_WORKSPACES: RAW_WORKSPACES } = process.env;

if (!ROOT_DIR) throw new EnvironmentError('ROOT_DIR');
if (!NODE_VERSION) throw new EnvironmentError('NODE_VERSION');
if (!isSemVer(NODE_VERSION)) throw new SemVerError(NODE_VERSION);

const IGNORED_FOLDERS = new Set(['src', 'dist', 'build', 'node_modules']);
const WORKSPACES = RAW_WORKSPACES?.trim().split(/[\s,]+/u) ?? [];

const ARG_NODE_VERSION_REGEX = /^ARG\s+NODE_VERSION(?:=.*)?$/iu;
const ARG_NODE_VERSION_REPLACEMENT = `ARG NODE_VERSION=${NODE_VERSION}`;

const FROM_NODE_REGEX =
  /^(FROM(?:\s+--platform=\S+)?\s+)(?:docker\.io\/library\/)?node:([^\s@]+)(?:@sha256:[a-fA-F0-9]+)?(.*)$/iu;

const digestCache = new Map();

function extractVariant(tag) {
  const variableMatch = /^(?:\$\{NODE_VERSION\}|\$NODE_VERSION)(.*)$/u.exec(tag);

  if (variableMatch) return variableMatch[1];

  const versionMatch = /^(\d+(?:\.\d+\.\d+)?)(.*)$/u.exec(tag);

  if (versionMatch && versionMatch.length > 2) return versionMatch[2];

  return null;
}

function resolveDigestViaBuildx(imageRef) {
  try {
    const output = execFileSync('docker', ['buildx', 'imagetools', 'inspect', imageRef], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    const match = /^Digest:\s+(sha256:[a-fA-F0-9]+)\s*$/mu.exec(output);

    return match?.[1] ?? null;
  } catch {
    return null;
  }
}

function resolveDigestViaRegistry(tag) {
  try {
    const tokenResponse = execFileSync(
      'curl',
      [
        '-fsSL',
        'https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/node:pull',
      ],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] },
    );
    const { token } = JSON.parse(tokenResponse);

    if (!token) return null;

    const headers = execFileSync(
      'curl',
      [
        '-fsSI',
        '-H',
        `Authorization: Bearer ${token}`,
        '-H',
        'Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.oci.image.manifest.v1+json, application/vnd.docker.distribution.manifest.v2+json',
        `https://registry-1.docker.io/v2/library/node/manifests/${tag}`,
      ],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] },
    );

    const match = /^docker-content-digest:\s*(sha256:[a-fA-F0-9]+)\s*$/imu.exec(headers);

    return match?.[1] ?? null;
  } catch {
    return null;
  }
}

function resolveImageDigest(tag) {
  if (digestCache.has(tag)) return digestCache.get(tag);

  const imageRef = `node:${tag}`;
  const digest = resolveDigestViaBuildx(imageRef) ?? resolveDigestViaRegistry(tag);

  if (!digest) {
    throw new Error(
      `Failed to resolve image digest for ${imageRef}. Ensure Docker Buildx or curl can reach the registry.`,
    );
  }

  digestCache.set(tag, digest);

  return digest;
}

function updateFromLine(line) {
  const match = FROM_NODE_REGEX.exec(line);

  if (!match) return line;

  const [, prefix, tag, suffix = ''] = match;

  if (match.length < 3 || !prefix || !tag) return line;

  const variant = extractVariant(tag);

  if (variant === null) return line;

  const pinnedTag = `${NODE_VERSION}${variant}`;
  const digest = resolveImageDigest(pinnedTag);

  return `${prefix}node:${pinnedTag}@${digest}${suffix}`;
}

function updateDockerfile(filePath) {
  if (!fs.existsSync(filePath)) return;

  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  let isChanged = false;

  const updatedLines = lines.map((line) => {
    if (ARG_NODE_VERSION_REGEX.test(line)) {
      isChanged = true;

      return ARG_NODE_VERSION_REPLACEMENT;
    }

    const updatedLine = updateFromLine(line);

    if (updatedLine !== line) isChanged = true;

    return updatedLine;
  });

  if (isChanged) fs.writeFileSync(filePath, updatedLines.join('\n'));
}

function walk(dirPath) {
  if (!fs.existsSync(dirPath)) return;

  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    if (!entry.isDirectory()) {
      if (entry.name === 'Dockerfile' || entry.name.startsWith('Dockerfile.')) {
        updateDockerfile(path.join(dirPath, entry.name));
      }
      continue;
    }

    if (!IGNORED_FOLDERS.has(entry.name) && !entry.name.startsWith('.')) {
      walk(path.join(dirPath, entry.name));
    }
  }
}

for (const workspace of WORKSPACES) {
  walk(path.join(ROOT_DIR, workspace));
}
