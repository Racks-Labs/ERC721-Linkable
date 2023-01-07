/** @type {import("prettier").Config} */
module.exports = {
  printWidth: 80,
  singleQuote: true,
  trailingComma: 'all',
  tabWidth: 2,
  semi: false,
  overrides: [
    {
      files: '*.sol',
      options: {
        printWidth: 80,
        tabWidth: 4,
        useTabs: false,
        singleQuote: false,
        bracketSpacing: false,
      },
    },
  ],
}
