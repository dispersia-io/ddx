#!/usr/bin/env node

const path = require('node:path');
const { spawnSync } = require('node:child_process');

const cliPath = path.join(__dirname, 'cli.sh');

const result = spawnSync('bash', [cliPath, ...process.argv.slice(2)], {
  stdio: 'inherit',
});

process.exit(result.status ?? 1);
