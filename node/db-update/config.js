const { join } = require('path')
require('dotenv').config({ path: join(__dirname, '../.env') })

module.exports = {
  MONGODB_CONNECTION: process.env.MONGODB_CONNECTION || false,
  MONGODB_USERS_COLLECTION: process.env.MONGODB_USERS_COLLECTION || '',
  MONGODB_USERS_NAME: process.env.MONGODB_USERS_NAME || '',
  MONGODB_SDS_COLLECTION: process.env.MONGODB_SDS_COLLECTION || '',
  MONGODB_SDS_NAME: process.env.MONGODB_SDS_NAME || ''
}
