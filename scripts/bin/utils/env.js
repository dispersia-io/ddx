/* eslint-disable max-classes-per-file */

/**
 * Provides custom error classes and validation utilities
 * for environment variables and semantic versioning.
 */

class EnvironmentError extends Error {
  constructor(varname) {
    super(`Environment variable '${varname}' is not defined`);
    this.name = 'EnvironmentError';
  }
}

class SemVerError extends Error {
  constructor(version) {
    super(`Invalid SemVer format: "${version}"`);
    this.name = 'SemVerError';
  }
}

const isSemVer = (version) => typeof version === 'string' && /^\d+\.\d+\.\d+$/u.test(version);

module.exports = {
  isSemVer,
  SemVerError,
  EnvironmentError,
};
