const { writeFileSync } = require('fs')
const { join } = require('path')
const capitalize = require('capitalize')
const schoolVariants = require('./schools-variants')
const sections = require('../data/section.json')

/**
 * Merge all users of one personType with theire enrollments
 * @param {String} personType student / teacher - Which personType of person to merge enrollments for
 * @param {Boolean} debug true / false if consonle.log should be performed. Default = false
 */
module.exports = (personType, debug = false) => {
  const personEnrollments = require(personType.toLowerCase() === 'student' ? '../data/studentenrollment.json' : '../data/teacherroster.json')
  const persons = require(personType.toLowerCase() === 'student' ? '../data/student.json' : '../data/teacher.json')
  const type = capitalize(personType)
  debug && console.log('merge-persons', `${personType}s`, persons.length)

  const mergedSAMs = [] // samAccountName's of people merged
  const mergedPeople = []
  for (const p of persons) {
    const samAccountName = p['SIS ID']
    const userPrincipalName = p.Username

    // person might have multiple schools (mulitple person objects), must get all schools AND not rerun this person ever again!
    if (mergedSAMs.includes(samAccountName)) continue
    else mergedSAMs.push(samAccountName)
    const pers = persons.filter(per => per['SIS ID'] === samAccountName)
    const obj = {
      samAccountName,
      userPrincipalName,
      timestamp: new Date(new Date().getTime() - (new Date().getTimezoneOffset() * 60000)).toISOString(),
      sds: []
    }

    pers.forEach(perObj => {
      // person
      const schoolId = perObj['School SIS ID']
      const schoolIdObj = schoolVariants[schoolId]
      const schoolIdVariants = schoolIdObj.variants
      const schoolName = schoolIdObj.name
      const status = perObj.Status

      const person = {
        samAccountName,
        schoolId,
        schoolName,
        schoolIdVariants,
        userPrincipalName,
        status,
        type
      }

      // find enrollments for this person && enrollments for the schools this person is attending
      const myEnrollments = personEnrollments.filter(enrollment => enrollment['SIS ID'] === samAccountName && enrollment['Section SIS ID'].match(`(${schoolIdVariants.join(')|(')})`))

      // find section info for each enrollment
      const enrollments = myEnrollments.map(enrollment => {
        const sectionId = enrollment['Section SIS ID']
        const section = sections.find(sect => sect['SIS ID'] === sectionId)
        if (!section) {
          console.warn(`Section not found for ${sectionId} for ${type} ${samAccountName} @ ${schoolName}`)
          return {
            sectionId,
            schoolId: '',
            sectionName: '',
            sectionCourseDescription: ''
          }
        }

        return {
          sectionId,
          schoolId: section['School SIS ID'],
          sectionName: section['Section Name'],
          sectionCourseDescription: section['Course Description']
        }
      })

      obj.sds.push({
        person,
        enrollments
      })
    })

    mergedPeople.push(obj)
  }

  // save mergedPeople to file
  writeFileSync(join(__dirname, `..\\data\\merged${type}s.json`), JSON.stringify(mergedPeople, null, 2), 'utf8')
}
