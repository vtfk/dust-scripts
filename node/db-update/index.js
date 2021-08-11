(async () => {
  const mongo = require('./lib/mongo')
  const data = require('./data/users.json')
  const db = await mongo()

  try {
    console.log('lib', 'update-database', 'clear collection')
    await db.deleteMany({})
  } catch (error) {
    console.warn('lib', 'update-database', 'unable to clear collection', error)
    process.exit(1)
  }

  console.log('lib', 'update-database', 'insert data', data.length, 'start')
  try {
    const result = await db.insertMany(data)
    console.log('lib', 'update-database', 'insert data', 'inserted', result.insertedCount)
  } catch (error) {
    console.error('lib', 'update-database', 'update data', 'failed to insert data', error)
    process.exit(2)
  }

  console.log('lib', 'update-database', 'finished')
  process.exit(0)
})()
