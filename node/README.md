# dust-scripts / node

Node scripts used by PowerShell for DUST

## Setup

### .env

Create a `.env` file in node root folder with this content:
```bash
MONGODB_CONNECTION=mongodb+srv://<username>:<password>@<server>?retryWrites=true&w=majority
MONGODB_USERS_COLLECTION=collectionname
MONGODB_USERS_NAME=databasename
MONGODB_SDS_COLLECTION=collectionname
MONGODB_SDS_NAME=databasename
SDS_PATH=<path-to-folder-containing-SDS-csv-files>
```

## Scripts

### db-update

**Must be called with one of the required types**:
- *users*
- *sds*

Remove all users from db and update db with users from `.\db-update\data\users.json`
```bash
node .\index.js users
```

Remove all sds users from db and update db with sds users from `.\db-update\data\sds.json`
```bash
node .\index.js sds
```

### sds-update

1. Converts all SDS files from *.csv* to *.json* and saves them to `.\sds-update\data\`
1. Finds and creates a sds object for each **student** / **teacher**. If **student** / **teacher** has mulitple school connections, each connection will be listed in the `sds` array
    ```json
    {
      "samAccountName": "tes0101",
      "userPrincipalName": "test.testesen@skole.vtfk.no",
      "sds": [
        {
          "person": {
            "samAccountName": "tes0101",
            "schoolId": "OF-SFV",
            "schoolName": "Sandefjord videregående skole",
            "schoolIdVariants": [
              "SFVS",
              "SVGS",
              "OF-SFV",
              "SFV"
            ],
            "userPrincipalName": "test.testesen@skole.vtfk.no",
            "status": "Active",
            "type": "Student"
          },
          "enrollments": [
            {
              "sectionId": "2122-OF-SFV-1319386",
              "schoolId": "OF-SFV",
              "sectionName": "OF-SFV-1SSD-nedlagt-Klasse",
              "sectionCourseDescription": "Basisgruppe 1SSDnedlagt ved Sandefjord videregående skole"
            },
            {
              "sectionId": "2122-OF-SFV-10110540",
              "schoolId": "OF-SFV",
              "sectionName": "OF-SFV-1SSD-nedlagt Yrkesfaglig fordypning vg1",
              "sectionCourseDescription": "Undervisningsgruppe 1SSDnedlagt/YFF4106 ved Sandefjord videregående skole"
            },
            {
              "sectionId": "2122-OF-SFV-10110286",
              "schoolId": "OF-SFV",
              "sectionName": "OF-SFV-1SSD-nedlagt Matematikk 1P-Y SR",
              "sectionCourseDescription": "Undervisningsgruppe 1SSDnedlagt/MAT1127 ved Sandefjord videregående skole"
            },
            {
              "sectionId": "2122-OF-SFV-10110284",
              "schoolId": "OF-SFV",
              "sectionName": "OF-SFV-1SSD-nedlagt Forretningsdrift",
              "sectionCourseDescription": "Undervisningsgruppe 1SSDnedlagt/SSR1001 ved Sandefjord videregående skole"
            },
            {
              "sectionId": "2122-OF-SFV-10110750",
              "schoolId": "OF-SFV",
              "sectionName": "OF-SFV-2SRA Forretningsdrift",
              "sectionCourseDescription": "Undervisningsgruppe 2SRA/SRL2001 ved Sandefjord videregående skole"
            },
            {
              "sectionId": "2122-OF-SFV-10110270",
              "schoolId": "OF-SFV",
              "sectionName": "OF-SFV-1SSB Forretningsdrift",
              "sectionCourseDescription": "Undervisningsgruppe 1SSB/SSR1001 ved Sandefjord videregående skole"
            },
            {
              "sectionId": "2122-OF-SFV-10110297",
              "schoolId": "OF-SFV",
              "sectionName": "OF-SFV-1SSB Yrkesfaglig fordypning vg1",
              "sectionCourseDescription": "Undervisningsgruppe 1SSB/YFF4106 ved Sandefjord videregående skole"
            },
            {
              "sectionId": "2122-OF-SFV-10110272",
              "schoolId": "OF-SFV",
              "sectionName": "OF-SFV-1SSB Matematikk 1P-Y SR",
              "sectionCourseDescription": "Undervisningsgruppe 1SSB/MAT1127 ved Sandefjord videregående skole"
            }
          ]
        }
      ]
    }
    ```
1. Merges `students` and `teachers` to `..\db-update\data\sds.json`
1. Calls `db-update\\index.js` to update db with sds users from `..\db-update\data\sds.json`
