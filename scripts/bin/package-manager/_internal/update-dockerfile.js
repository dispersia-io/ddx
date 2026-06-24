const fs = require('node:fs');
const path = require('node:path');
const { EnvironmentError, SemVerError, isSemVer } = require('../../utils/env.js');

const { ROOT_DIR, PM_NAME, PM_VERSION, PM_WORKSPACES: RAW_WORKSPACES } = process.env;

if (!ROOT_DIR) throw new EnvironmentError('ROOT_DIR');
if (!PM_NAME) throw new EnvironmentError('PM_NAME');
if (!PM_VERSION) throw new EnvironmentError('PM_VERSION');
if (!isSemVer(PM_VERSION)) throw new SemVerError(PM_VERSION);

const IGNORED_FOLDERS = new Set(['src', 'dist', 'build', 'node_modules']);
const WORKSPACES = RAW_WORKSPACES?.trim().split(/[\s,]+/u) ?? [];

const COREPACK_REGEX = new RegExp(`corepack prepare ${PM_NAME}@[0-9\\.]+`, 'gu');
const COREPACK_REPLACEMENT = `corepack prepare ${PM_NAME}@${PM_VERSION}`;

function updateDockerfile(filePath) {
  if (!fs.existsSync(filePath)) return;

  const content = fs.readFileSync(filePath, 'utf8');

  if (COREPACK_REGEX.test(content)) {
    fs.writeFileSync(filePath, content.replace(COREPACK_REGEX, COREPACK_REPLACEMENT));
  }
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
