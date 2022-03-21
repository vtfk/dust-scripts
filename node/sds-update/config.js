const { join } = require('path')
require('dotenv').config({ path: join(__dirname, '../.env') })

module.exports = {
  SDS_PATH: process.env.SDS_PATH,
  SDS_DELIMITER: process.env.SDS_DELIMITER || ','
}
