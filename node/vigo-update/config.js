const { join } = require('path')
require('dotenv').config({ path: join(__dirname, '../.env') })

module.exports = {
  ot: {
    uri: process.env.VIGO_OT_URI,
    apiKey: process.env.VIGO_OT_API_KEY,
    fylkesnr: process.env.VIGO_OT_COUNTY,
    accept: process.env.VIGO_OT_ACCEPT || 'application/json'
  },
  laerling: {
    uri: process.env.VIGO_LAERLING_URI,
    apiKey: process.env.VIGO_LAERLING_API_KEY,
    fylkesnr: process.env.VIGO_LAERLING_COUNTY,
    accept: process.env.VIGO_LAERLING_ACCEPT || 'application/json'
  }
}
