# skrives om til å compare før insert / delete

# import environment variables
. .\envs.ps1

if (!$db.connectionString -or !$db.dbName -or !$db.dbCollection) {
    Write-Error "RTFM (DUST!)" -ErrorAction Stop
}

# get ad users from AUTO USERS
$loginUsers = D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "login.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,extensionAttribute6 -OnlyAutoUsers
$skoleUsers = D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "skole.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,department -OnlyAutoUsers

# get ad users from AUTO DISABLED USERS
$disabledLoginUsers = D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "login.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,extensionAttribute6 -OnlyDisabledAutoUsers
$disabledSkoleUsers = D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "skole.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,department -OnlyDisabledAutoUsers

# connect to MONGO
Connect-Mdbc -ConnectionString $db.connectionString -DatabaseName $db.dbName -CollectionName $db.dbCollection

# purge all users from $db.dbName
Remove-MdbcData -Many -Filter "{}"

# add all users to MONGO
$loginUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"login"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, @{N="departmentShort"; E={$_.extensionAttribute6}} | Add-MdbcData
$skoleUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"skole"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, @{N="departmentShort"; E={$_.department}} | Add-MdbcData

# add all disabled users to MONGO
$disabledLoginUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"login"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, @{N="departmentShort"; E={$_.extensionAttribute6}} | Add-MdbcData
$disabledSkoleUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"skole"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, @{N="departmentShort"; E={$_.department}} | Add-MdbcData