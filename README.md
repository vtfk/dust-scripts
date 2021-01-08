# dust-scripts

Scripts for DUST

## Setup

Create a `envs.ps1` file with this content:
```PowerShell
$connectionString = "mongodb+srv://<username>:<password>@<sørver>?retryWrites=true&w=majority"
$dbName = "databasename"
$dbCollection = "collectionname"
```

## Database

- Create database in MONGO
- Create a new collection in the database
- Create a new user with only `readWrite` permissions to the new collection
