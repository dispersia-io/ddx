/**
 * This is an internal script. Do not run it directly.
 * Relies on variables from the parent script: DEPENDABOT_FILE, PACKAGES_ENV, IS_SILENT
 */

const fs = require('node:fs');
const yaml = require('yaml');
const { EnvironmentError } = require('../../utils/env.js');

let isSilent = false;

try {
  isSilent = (() => {
    const value = process.env.IS_SILENT ?? '';

    if (/^(1|true)$/iu.test(value)) return true;
    if (/^(0|false)?$/iu.test(value)) return false;
    throw new Error(`Unrecognized boolean-like value '${value}'`);
  })();

  const yamlPath = process.env.DEPENDABOT_FILE;

  if (!yamlPath) throw new EnvironmentError('DEPENDABOT_FILE');

  const yamlContent = fs.readFileSync(yamlPath, 'utf8');
  const yamlDoc = yamlContent.trim() ? yaml.parseDocument(yamlContent) : new yaml.Document();

  const unstablePackagesEnv = process.env.PACKAGES_ENV ?? '';
  const unstablePackages = [...new Set(unstablePackagesEnv.split(/\s+/u).filter(Boolean))];

  let isChanged = false;

  if (!yamlDoc.has('version')) {
    yamlDoc.set('version', 2);
    isChanged = true;
  }

  if (!yamlDoc.has('updates') || !yaml.isSeq(yamlDoc.get('updates'))) {
    yamlDoc.set('updates', yamlDoc.createNode([]));
    isChanged = true;
  }

  const updates = yamlDoc.get('updates');

  let npmUpdateMap = updates.items.find(
    (item) => yaml.isMap(item) && item.get('package-ecosystem') === 'npm',
  );

  if (!npmUpdateMap) {
    updates.add(
      (npmUpdateMap = yamlDoc.createNode({
        'package-ecosystem': 'npm',
        directory: '/',
        schedule: { interval: 'daily' },
        labels: ['deps', 'node', 'dependabot'],
        ignore: [],
      })),
    );
    isChanged = true;
  }

  if (!npmUpdateMap.has('ignore') || !yaml.isSeq(npmUpdateMap.get('ignore'))) {
    npmUpdateMap.set('ignore', yamlDoc.createNode([]));
    isChanged = true;
  }

  const ignoreSeq = npmUpdateMap.get('ignore');

  const findIgnored = (name) => {
    return ignoreSeq.items.find((item) => yaml.isMap(item) && item.get('dependency-name') === name);
  };

  const ignore = (name, semver) => {
    const existingItem = findIgnored(name);
    const type = `version-update:semver-${semver}`;

    if (!existingItem) {
      const item = yamlDoc.createNode({ 'dependency-name': name, 'update-types': [type] });

      item.get('update-types').flow = true;
      ignoreSeq.add(item);
      isChanged = true;
      return;
    }

    if (!existingItem.has('update-types') || !yaml.isSeq(existingItem.get('update-types'))) {
      const typesSeq = yamlDoc.createNode([type]);

      typesSeq.flow = true;
      existingItem.set('update-types', typesSeq);
      isChanged = true;
      return;
    }

    const typesSeq = existingItem.get('update-types');
    const hasType = typesSeq.items.some((item) => item?.value === type);

    if (!typesSeq.flow) {
      typesSeq.flow = true;
      isChanged = true;
    }

    if (!hasType) {
      typesSeq.add(type);
      isChanged = true;
    }
  };

  ignore('*', 'major');

  for (const name of unstablePackages) {
    ignore(name, 'minor');
  }

  if (isChanged) {
    fs.writeFileSync(yamlPath, yamlDoc.toString());
    console.log('UPDATED');
  } else {
    console.log('SKIPPED');
  }
} catch (error) {
  if (!isSilent) console.error(`Error updating dependabot config: ${error.message}`);
  process.exit(1);
}
