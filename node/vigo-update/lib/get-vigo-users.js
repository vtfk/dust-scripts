const axios = require('axios').default
const config = require('../config')

module.exports = async type => {
  try {
    const { uri, apiKey, fylkesnr, accept } = config[type]
    const options = {
      headers: {
        'api-key': apiKey,
        fylkesnr,
        accept
      }
    }

    const { data } = await axios.get(uri, options)
    return data
  } catch (error) {
    console.log('Oh no:', error)
    return {}
  }
}
