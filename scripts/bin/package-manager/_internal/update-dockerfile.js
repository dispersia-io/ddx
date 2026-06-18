const fs = require('fs');
const path = require('path');

const { ROOT_DIR, VERSION, PACKAGE_MANAGER, WORKSPACES: RAW_WORKSPACES } = process.env;

const IGNORED_FOLDERS = ['src', 'dist', 'build', 'node_modules'];
const WORKSPACES = RAW_WORKSPACES?.trim().split(/[\s,]+/) ?? [];

const COREPACK_REGEX = new RegExp(`corepack prepare ${PACKAGE_MANAGER}@[0-9\\.]+`, 'g');
const COREPACK_REPLACEMENT = `corepack prepare ${PACKAGE_MANAGER}@${VERSION}`;

function updateDockerfile(filePath) {
  if (!fs.existsSync(filePath)) return;

  const content = fs.readFileSync(filePath, 'utf8');

  if (content.match(COREPACK_REGEX)) {
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

    if (!IGNORED_FOLDERS.includes(entry.name) && !entry.name.startsWith('.')) {
      walk(path.join(dirPath, entry.name));
    }
  }
}

for (const workspace of WORKSPACES) {
  walk(path.join(ROOT_DIR, workspace));
}
