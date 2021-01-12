﻿# dust-scripts

Scripts for DUST

## Setup

Create a `envs.ps1` file with this content:
```PowerShell
$db = @{
  connectionString = "mongodb+srv://<username>:<password>@<server>?retryWrites=true&w=majority"
  dbName = "databasename"
  dbCollection = "collectionname"
}

$visma = @{
  baseUri = "<visma-hrm-address>"
  username = "<username>"
  password = "<password>"
}

$ad = @{
  baseUnit = "<OU-PATH>,DC=%domain%,DC=<subforrest>,DC=<subsubforrest>" # '%domain%' MUST be left as is! Change '<OU-PATH>', '<subforrest>' and '<subsubforrest>'. Remove those not in use.
  autoUsers = "<USERS-OU-PATH>" # OU path your auto users. Don't include baseUnit OU path
  disabledUsers = "<DISABLED-USERS-OU-PATH>" # OU path your disabled auto users. Don't include baseUnit OU path
}
```

## Database

- Create database in MONGO
- Create a new collection in the database
- Create a new user with only `readWrite` permissions to the new collection
