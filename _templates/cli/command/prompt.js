const fs = require('fs');
const path = require('path');

const toKebabCase = (value) =>
  value.toLowerCase().trim().replaceAll(' ', '-').replaceAll(/-{2,}/gu, '-');

const toUpperSnakeCase = (value) =>
  value.toUpperCase().replaceAll('-', '_').replaceAll(/_{2,}/gu, '_');

const removeFlag = (value) => value.replace(/^-+/u, '');

module.exports = {
  prompt: ({ prompter }) => {
    return prompter
      .prompt([
        {
          type: 'input',
          name: 'command',
          message: 'Enter command name (e.g. deps, env, symlink):',
          result: (input) => removeFlag(toKebabCase(input)),
          validate: (input) => input.trim() !== '' || 'Command name is required',
        },
        {
          type: 'input',
          name: 'subcommand',
          message: 'Enter subcommand name (e.g. init, create, push):',
          result: (input) => removeFlag(toKebabCase(input)),
          validate: (input) => input.trim() !== '' || 'Subcommand name is required',
        },
        {
          type: 'input',
          name: 'alias',
          message: 'Enter subcommand short alias (optional):',
          result: (input) => removeFlag(toKebabCase(input)),
        },
        {
          type: 'input',
          name: 'description',
          message: 'Enter short description (optional):',
          result: (input) => input.trim(),
        },
      ])
      .then((inputs) => {
        const commandDir = path.join(process.cwd(), 'scripts/bin', inputs.command);
        const doesCommandExist = fs.existsSync(commandDir);

        if (doesCommandExist) {
          const doesSubcommandExist = fs.existsSync(
            path.join(commandDir, `${inputs.subcommand}.sh`),
          );

          if (doesSubcommandExist) {
            throw new Error(`Subcommand "${inputs.command} ${inputs.subcommand}" already exists`);
          }
        }

        return {
          ...inputs,
          description: inputs.description || 'No description provided',
          command_upper: inputs.command.toUpperCase().replaceAll('-', '_'),
          subcommand_upper: inputs.subcommand.toUpperCase().replaceAll('-', '_'),
        };
      });
  },
};
