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

const START_TAG = '<!--yarn-version-->';
const END_TAG = '<!--/yarn-version-->';
const TAGS_REGEX = new RegExp(`${START_TAG}.*?${END_TAG}`, 'gu');

function updateDocument(filePath) {
  if (!fs.existsSync(filePath)) return;

  const content = fs.readFileSync(filePath, 'utf8');

  if (content.includes(START_TAG) && content.includes(END_TAG)) {
    const updatedContent = content.replace(TAGS_REGEX, `${START_TAG}${PM_VERSION}${END_TAG}`);

    fs.writeFileSync(filePath, updatedContent);
  }
}

function walk(dirPath) {
  if (!fs.existsSync(dirPath)) return;

  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    if (!entry.isDirectory()) {
      if (path.extname(entry.name).toLowerCase() === '.md') {
        updateDocument(path.join(dirPath, entry.name));
      }
      continue;
    }

    if (!IGNORED_FOLDERS.includes(entry.name) && !entry.name.startsWith('.')) {
      walk(path.join(dirPath, entry.name));
    }
  }
}

for (const file of fs.readdirSync(ROOT_DIR, { withFileTypes: true })) {
  if (file.isFile() && path.extname(file.name).toLowerCase() === '.md') {
    updateDocument(path.join(ROOT_DIR, file.name));
  }
}

for (const workspace of WORKSPACES) {
  walk(path.join(ROOT_DIR, workspace));
}
