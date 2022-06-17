const repackOT = data => {
  return data.map(item => {
    return {
      ...item.person,
      ...item.otData,
      ...item.elevkurs,
      timestamp: new Date().toISOString()
    }
  })
}

const repackLaerling = data => {
  return data.map(item => {
    const newItem = {
      ...item.elev,
      ...item,
      timestamp: new Date().toISOString()
    }

    delete newItem.elev
    return newItem
  })
}

module.exports = data => {
  if (data.otungdommer) return repackOT(data.otungdommer)
  if (data.kontrakter) return repackLaerling(data.kontrakter)
  return null
}
