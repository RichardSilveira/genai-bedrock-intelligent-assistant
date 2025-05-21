const { execSync } = require('child_process')

/**
 * Run terraform fmt against multiple files
 *
 * @example node terraform-multi-fmt <path1> <path2> <path3>
 *
 * process.argv.slice(2) returns ["path1", "path2", "path3"]
 */
process.argv.slice(2).forEach((path) => {
  execSync(`terraform fmt ${path}`, { stdio: 'inherit' })
})
