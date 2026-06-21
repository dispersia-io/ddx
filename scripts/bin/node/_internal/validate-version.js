const MIN_NODE_VERSION = process.env.MIN_NODE_VERSION;

if (typeof MIN_NODE_VERSION !== 'string' || !/^\d+\.\d+\.\d+$/u.test(MIN_NODE_VERSION)) {
  console.error(`Invalid Node.js version format: "${MIN_NODE_VERSION}"`);
  process.exit(1);
}

const required = MIN_NODE_VERSION.split('.').map(Number);
const current = process.versions.node.split('.').map(Number);

const isValid =
  current[0] === required[0] &&
  (current[1] > required[1] || (current[1] === required[1] && current[2] >= required[2]));

process.exit(isValid ? 0 : 1);
