# dust-scripts / node

Node scripts used by PowerShell for DUST

## Setup

### .env

Create a `.env` file in node root folder with this content:
```bash
MONGODB_CONNECTION=mongodb+srv://<username>:<password>@<server>?retryWrites=true&w=majority
MONGODB_COLLECTION=collectionname
MONGODB_NAME=databasename
```

## Scripts

### db-update

Removes all users from db and updates db with users from `.\db-update\data\users.json`
```bash
node .\index.js
```
