# skrives om til å compare før insert / delete

. .\envs.ps1

if (!$connectionString -or !$dbName -or !$dbCollection) {
    Write-Error "RTFM (DUST!)" -ErrorAction Stop
}

# get ad loosers
$loginUsers = D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "login.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,extensionAttribute6 -OnlyAutoUsers
$skoleUsers = D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "skole.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,department -OnlyAutoUsers

# connect to MONGO
Connect-Mdbc -ConnectionString $connectionString -DatabaseName $dbName -CollectionName $dbCollection

# purge all loosers from dbName
Remove-MdbcData -Many -Filter "{}"

# add all loosers to MONGO
$loginUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"login"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, @{N="departmentShort"; E={$_.extensionAttribute6}} | Add-MdbcData
$skoleUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"skole"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, @{N="departmentShort"; E={$_.department}} | Add-MdbcData