const fs = require('fs');
const path = require('path');

const { ROOT_DIR, NEW_VERSION, PACKAGE_MANAGER, WORKSPACES: RAW_WORKSPACES } = process.env;

if (!ROOT_DIR || !NEW_VERSION || !PACKAGE_MANAGER) {
  throw new Error('Missing environment variables (ROOT_DIR, NEW_VERSION, or PACKAGE_MANAGER)');
}

const IGNORED_FOLDERS = ['src', 'dist', 'build', 'node_modules'];
const WORKSPACES = RAW_WORKSPACES?.trim().split(/[\s,]+/) ?? [];

const START_TAG = '<!--yarn-version-->';
const END_TAG = '<!--/yarn-version-->';
const TAGS_REGEX = new RegExp(`${START_TAG}.*?${END_TAG}`, 'gu');

function updateMarkdown(filePath) {
  if (!fs.existsSync(filePath)) return;

  const content = fs.readFileSync(filePath, 'utf8');

  if (content.includes(START_TAG) && content.includes(END_TAG)) {
    const updatedContent = content.replace(TAGS_REGEX, `${START_TAG}${NEW_VERSION}${END_TAG}`);

    fs.writeFileSync(filePath, updatedContent);
  }
}

function walk(dirPath) {
  if (!fs.existsSync(dirPath)) return;

  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    if (!entry.isDirectory()) {
      if (path.extname(entry.name).toLowerCase() === '.md') {
        updateMarkdown(path.join(dirPath, entry.name));
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
    updateMarkdown(path.join(ROOT_DIR, file.name));
  }
}

for (const workspace of WORKSPACES) {
  walk(path.join(ROOT_DIR, workspace));
}
