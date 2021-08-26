# dust-scripts

Scripts for DUST

## Setup

### envs.ps1

Create a `envs.ps1` file in root folder with this content:
```PowerShell
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

$feide = @{
    server = "<FQDN-to-feide-server>"
    searchBase = "OU=People,OU=Feide,DC=<feide-ou-name>,DC=no"
}

$sds = @{
    server = "<FQDN-to-sds-server-if-not-local>" # if files are local, set '.'
    folderPath = "<local-folder-path-to-sds-csv-files>"
    delimiter = ","
}

$idm = @{
  autoRun = "<unc-path-autorun-folder-for-post-scripts-from-idm>"
  file = "lastRun.txt"
}
```

## Database

- Create database in MONGO
- Create a new collection in the database
- Create a new user with only `readWrite` permissions to the new collection
