const MongoClient = require('mongodb').MongoClient
const { MONGODB_CONNECTION, MONGODB_COLLECTION, MONGODB_NAME } = require('../config')

let client = null

module.exports = function getMongoDb (fn) {
  if (!MONGODB_CONNECTION) {
    console.error('mongo', 'missing MONGODB_CONNECTION')
    throw new Error('Missing env MONGODB_CONNECTION')
  }
  if (client && !client.isConnected) {
    client = null
    console.log('mongo', 'discard client')
  }
  if (client === null) {
    client = new MongoClient(MONGODB_CONNECTION, { useNewUrlParser: true, useUnifiedTopology: true })
    console.log('mongo', 'new client init')
  } else if (client.isConnected) {
    console.log('mongo', 'client connected', 'quick return')
    return client.db(MONGODB_NAME).collection(MONGODB_COLLECTION)
  }

  return new Promise((resolve, reject) => {
    client.connect(error => {
      if (error) {
        client = null
        console.error('mongo', 'client error', error)
        return reject(error)
      } else {
        console.log('mongo', 'new client connected')
        resolve(client.db(MONGODB_NAME).collection(MONGODB_COLLECTION))
      }
    })
  })
}
