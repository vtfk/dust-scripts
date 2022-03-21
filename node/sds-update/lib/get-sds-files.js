const { parse } = require('csv-parse')
const { readdirSync, readFileSync, writeFileSync } = require('fs')
const { join } = require('path')
const { SDS_PATH, SDS_DELIMITER } = require('../config')

const parseCsv = (data, path) => {
  return new Promise((resolve, reject) => {
    const options = {
      bom: true,
      columns: true,
      delimiter: SDS_DELIMITER,
      encoding: 'utf8',
      skipEmptyLines: true
    }

    parse(data, options, (error, records) => {
      if (error) {
        console.log(`Failed to parse '${path}' :`, error)
        return reject(error)
      }

      return resolve(records)
    })
  })
}

module.exports = async (debug) => {
  try {
    const files = readdirSync(SDS_PATH)
    for await (const file of files) {
      const path = join(SDS_PATH, `\\${file}`)
      const jsonPath = join(__dirname, `..\\data\\${file.toLowerCase().replace('csv', 'json')}`)
      try {
        debug && console.log('Reading path:', path)
        const data = readFileSync(path, 'utf8')
        debug && console.log('\tPath read')
        const json = await parseCsv(data, path)
        debug && console.log('\tJson parsed')
        debug && console.log('\tWriting JSON to:', jsonPath)
        writeFileSync(jsonPath, JSON.stringify(json, null, 2), 'utf8')
        debug && console.log('\tJSON written')
      } catch (fileError) {
        console.log(`Failed to read/parse/write '${path}' / '${jsonPath}' :`, fileError)
      }
    }
  } catch (dirError) {
    console.log(`Failed to read files from '${SDS_PATH}' :`, dirError)
    throw dirError
  }
}
