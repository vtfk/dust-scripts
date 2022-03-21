(async () => {
  const { writeFileSync } = require('fs')
  const { join } = require('path')
  const { execFile } = require('child_process')
  const parseFiles = require('./lib/get-sds-files')
  const debug = false

  // convert sds files
  debug && console.log('Parsing SDS files')
  console.time('parseSdsFiles')
  await parseFiles(debug)
  console.timeEnd('parseSdsFiles')
  debug && console.log('Parsing SDS files finished')

  // this can't be required before one of it's dependencies has been created above.....
  const mergePersons = require('./lib/merge-persons')

  // merge students to export
  debug && console.log('Calling student merge')
  console.time('mergeStudents')
  mergePersons('student', debug)
  console.timeEnd('mergeStudents')
  debug && console.log('Student merge calling finished')

  // merge teachers to export
  debug && console.log('Calling teacher merge')
  console.time('mergeTeachers')
  mergePersons('teacher', debug)
  console.timeEnd('mergeTeachers')
  debug && console.log('Teacher merge calling finished')

  // merge students and teachers together to sds
  console.time('mergeToSDS')
  const sds = [
    ...require('.\\data\\mergedStudents.json'),
    ...require('.\\data\\mergedTeachers.json')
  ]
  console.timeEnd('mergeToSDS')
  writeFileSync(join(__dirname, '..\\db-update\\data\\sds.json'), JSON.stringify(sds, null, 2), 'utf8')

  // write sds data to db
  console.time('updateDB')
  execFile('node', ['..\\db-update\\index.js', 'sds'], { cwd: __dirname }, (error, stdout, stderr) => {
    if (error) {
      console.log('Error:', error)
    }
    if (stderr) {
      console.log('StdErr:', stderr)
    }
    if (stdout) {
      console.log(stdout)
    }
    console.timeEnd('updateDB')
    process.exit(0)
  })
})()
