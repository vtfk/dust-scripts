(async () => {
  const args = process.argv.slice(2)
  if (args.length === 0) {
    console.warn('lib', 'update-database', 'Tell me what update to do!\n- users\n- sds')
    process.exit(1)
  }
  const updateType = args[0].toLowerCase()
  const mongo = require('./lib/mongo')
  const data = require(`./data/${updateType}.json`)
  const db = await mongo(updateType)

  try {
    console.log('lib', 'update-database', updateType, 'clear collection')
    await db.deleteMany({})
  } catch (error) {
    console.warn('lib', 'update-database', updateType, 'unable to clear collection', error)
    process.exit(1)
  }

  console.log('lib', 'update-database', updateType, 'insert data', data.length, 'start')
  try {
    const result = await db.insertMany(data)
    console.log('lib', 'update-database', updateType, 'insert data', 'inserted', result.insertedCount)
  } catch (error) {
    console.error('lib', 'update-database', updateType, 'update data', 'failed to insert data', error)
    process.exit(2)
  }

  console.log('lib', 'update-database', updateType, 'finished')
  process.exit(0)
})()
