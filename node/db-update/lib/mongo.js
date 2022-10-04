const MongoClient = require('mongodb').MongoClient
const config = require('../config')
const { MONGODB_CONNECTION } = config

let client = null

module.exports = type => {
  if (!MONGODB_CONNECTION) {
    console.error('mongo', 'missing MONGODB_CONNECTION')
    throw new Error('Missing env MONGODB_CONNECTION')
  }

  if (client === null) {
    client = new MongoClient(MONGODB_CONNECTION)
    console.log('mongo', 'new client init')
  } else {
    console.log('mongo', 'client already exists. quick return')
  }

  return client.db(config[`MONGODB_${type.toUpperCase()}_NAME`]).collection(config[`MONGODB_${type.toUpperCase()}_COLLECTION`])
}
