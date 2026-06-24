import prettier from 'eslint-config-prettier';
import { configure } from 'eslint-config-woofmeow';
import globals from 'globals';

// eslint-disable-next-line no-restricted-exports
export default configure(
  {
    files: ['scripts/**/*.js'],
    languageOptions: {
      globals: { ...globals.node },
    },
    rules: {
      'no-console': 'off',
      'unicorn/no-process-exit': 'off',
      'unicorn/prefer-module': 'off',
    },
  },
  prettier,
);
