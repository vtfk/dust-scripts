# dust-scripts

Scripts for DUST

## Setup

Create a `envs.ps1` file with this content:
```PowerShell
$db = @{
  connectionString = "mongodb+srv://<username>:<password>@<server>?retryWrites=true&w=majority"
  dbName = "databasename"
  dbCollection = "collectionname"
}
```

## Database

- Create database in MONGO
- Create a new collection in the database
- Create a new user with only `readWrite` permissions to the new collection
