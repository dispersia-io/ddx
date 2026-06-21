const fs = require('fs');
const path = require('path');
const { EnvironmentError, SemVerError, isSemVer } = require('../../utils/env.js');

const { ROOT_DIR, PM_NAME, PM_VERSION, PM_WORKSPACES: RAW_WORKSPACES } = process.env;

if (!ROOT_DIR) throw new EnvironmentError('ROOT_DIR');
if (!PM_NAME) throw new EnvironmentError('PM_NAME');
if (!PM_VERSION) throw new EnvironmentError('PM_VERSION');
if (!isSemVer(PM_VERSION)) throw new SemVerError(PM_VERSION);

const IGNORED_FOLDERS = ['src', 'dist', 'build', 'node_modules'];
const WORKSPACES = RAW_WORKSPACES?.trim().split(/[\s,]+/) ?? [];

function updatePackageJson(filePath) {
  if (!fs.existsSync(filePath)) return;

  try {
    const json = JSON.parse(fs.readFileSync(filePath, 'utf8'));

    json.packageManager = `${PM_NAME}@${PM_VERSION}`;

    fs.writeFileSync(filePath, `${JSON.stringify(json, null, 2)}\n`);
  } catch {}
}

function walk(dirPath) {
  if (!fs.existsSync(dirPath)) return;

  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    if (!entry.isDirectory()) {
      if (entry.name === 'package.json') updatePackageJson(path.join(dirPath, entry.name));
      continue;
    }

    if (!IGNORED_FOLDERS.includes(entry.name) && !entry.name.startsWith('.')) {
      walk(path.join(dirPath, entry.name));
    }
  }
}

updatePackageJson(path.join(ROOT_DIR, 'package.json'));

for (const workspace of WORKSPACES) {
  walk(path.join(ROOT_DIR, workspace));
}
