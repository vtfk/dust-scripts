require('dotenv').config()
const args = process.argv.slice(2)

if (args.length <= 0) {
  console.log('ERROR: Missing EmployeeNumber')
  process.exit(-1)
}

const pifu = require(process.env.PIFU_FILE_PATH)
const employeeNumber = args[0]

// find person
const person = pifu.enterprise.person.find(p => p.sourcedid.id === Number.parseInt(employeeNumber))

// find memberships
const id = person ? person.sourcedid.id : Number.parseInt(employeeNumber)
const memberships = pifu.enterprise.membership.filter(membership => membership && Array.isArray(membership.member) && !!membership.member.find(member => member.sourcedid && member.sourcedid.id === id))
  .map(ships => {
    ships.member = ships.member.find(member => member.sourcedid && member.sourcedid.id === id)
    return ships
  })

if (!person && (!memberships || memberships.length === 0)) {
  // ERROR: Person object and memberships not found
  console.log("[]")
  process.exit(-1)
}

console.log(JSON.stringify({
  person,
  memberships
}))
