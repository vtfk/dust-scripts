require('dotenv').config({ path: '../.env' })

module.exports = {
  MONGODB_CONNECTION: process.env.MONGODB_CONNECTION || false,
  MONGODB_COLLECTION: process.env.MONGODB_COLLECTION || '',
  MONGODB_NAME: process.env.MONGODB_NAME || ''
}
