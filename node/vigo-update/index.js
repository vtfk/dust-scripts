(async () => {
  const { writeFileSync } = require('fs')
  const { join } = require('path')
  const { execFile } = require('child_process')
  const getVigoUsers = require('./lib/get-vigo-users')
  const repackData = require('./lib/repack-data')

  const args = process.argv.slice(2)
  if (args.length === 0) {
    console.warn('lib', 'update-vigo', 'Tell me what update to do!\n- ot\n- laerling')
    process.exit(1)
  } else if (args[0].toLowerCase() !== 'ot' && args[0].toLowerCase() !== 'laerling') {
    console.warn('lib', 'update-vigo', 'Invalid update type', 'Use:\n- ot\n- laerling')
    process.exit(1)
  }
  const type = args[0].toLowerCase()

  const vigoData = await getVigoUsers(type)
  const data = repackData(vigoData)
  writeFileSync(join(__dirname, `..\\db-update\\data\\${type}.json`), JSON.stringify(data, null, 2), 'utf8')

  // write updateType data to db
  console.time(`updateDB-vigo-${type}`)
  execFile('node', ['..\\db-update\\index.js', type], { cwd: __dirname }, (error, stdout, stderr) => {
    if (error) {
      console.log('Error:', error)
    }
    if (stderr) {
      console.log('StdErr:', stderr)
    }
    if (stdout) {
      console.log(stdout)
    }
    console.timeEnd(`updateDB-vigo-${type}`)
    process.exit(0)
  })
})()
