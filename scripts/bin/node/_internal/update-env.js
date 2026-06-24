const fs = require('node:fs');
const path = require('node:path');
const { EnvironmentError, SemVerError, isSemVer } = require('../../utils/env.js');

const { ROOT_DIR, NODE_VERSION, NODE_WORKSPACES: RAW_WORKSPACES } = process.env;

if (!ROOT_DIR) throw new EnvironmentError('ROOT_DIR');
if (!NODE_VERSION) throw new EnvironmentError('NODE_VERSION');
if (!isSemVer(NODE_VERSION)) throw new SemVerError(NODE_VERSION);

const IGNORED_FOLDERS = new Set(['src', 'dist', 'build', 'node_modules']);
const WORKSPACES = RAW_WORKSPACES?.trim().split(/[\s,]+/u) ?? [];

const ENV_VERSION_REGEX = /^NODE_VERSION=.*/mu;
const ENV_VERSION_REPLACEMENT = `NODE_VERSION=${NODE_VERSION}`;

const MAJOR_VERSION = NODE_VERSION?.split('.')[0];
const ENV_MAJOR_VERSION_REGEX = /^NODE_MAJOR_VERSION=.*/mu;
const ENV_MAJOR_VERSION_REPLACEMENT = `NODE_MAJOR_VERSION=${MAJOR_VERSION}`;

function updateEnv(filePath) {
  if (!fs.existsSync(filePath)) return;

  const content = fs.readFileSync(filePath, 'utf8');

  if (ENV_VERSION_REGEX.test(content) || ENV_MAJOR_VERSION_REGEX.test(content)) {
    fs.writeFileSync(
      filePath,
      content
        .replace(ENV_VERSION_REGEX, ENV_VERSION_REPLACEMENT)
        .replace(ENV_MAJOR_VERSION_REGEX, ENV_MAJOR_VERSION_REPLACEMENT),
    );
  }
}

function walk(dirPath) {
  if (!fs.existsSync(dirPath)) return;

  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    if (!entry.isDirectory()) {
      if (entry.name === '.env' || entry.name === '.env.example') {
        updateEnv(path.join(dirPath, entry.name));
      }
      continue;
    }

    if (!IGNORED_FOLDERS.has(entry.name) && !entry.name.startsWith('.')) {
      walk(path.join(dirPath, entry.name));
    }
  }
}

updateEnv(path.join(ROOT_DIR, '.env'));
updateEnv(path.join(ROOT_DIR, '.env.example'));

for (const workspace of WORKSPACES) {
  walk(path.join(ROOT_DIR, workspace));
}
