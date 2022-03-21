const MongoClient = require('mongodb').MongoClient
const config = require('../config')
const { MONGODB_CONNECTION } = config

let client = null

module.exports = function getMongoDb (type) {
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
    return client.db(config[`MONGODB_${type.toUpperCase()}_NAME`]).collection(config[`MONGODB_${type.toUpperCase()}_COLLECTION`])
  }

  return new Promise((resolve, reject) => {
    client.connect(error => {
      if (error) {
        client = null
        console.error('mongo', 'client error', error)
        return reject(error)
      } else {
        console.log('mongo', 'new client connected')
        resolve(client.db(config[`MONGODB_${type.toUpperCase()}_NAME`]).collection(config[`MONGODB_${type.toUpperCase()}_COLLECTION`]))
      }
    })
  })
}
