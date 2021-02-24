# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

if (!$db.connectionString -or !$db.dbName -or !$db.dbCollection) {
    Write-Error "RTFM (DUST!)" -ErrorAction Stop
}

$adUsers = @()

# get ad users from AUTO USERS
$adUsers += D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "login.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,extensionAttribute4,extensionAttribute6,physicalDeliveryOfficeName -OnlyAutoUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"login"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, enabled, @{N="ou"; E={"AUTO USERS"}}, @{N="departmentShort"; E={$_.extensionAttribute6}}, @{N="departmentAdditional"; E={$_.extensionAttribute4}}, @{N="office"; E={$_.physicalDeliveryOfficeName}}
$adUsers += D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "skole.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,department,company -OnlyAutoUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"skole"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, enabled, @{N="ou"; E={"AUTO USERS"}}, @{N="departmentShort"; E={$_.department}}, @{N="office"; E={$_.company}}

# get ad users from AUTO DISABLED USERS
$adUsers += D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "login.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,extensionAttribute4,extensionAttribute6,physicalDeliveryOfficeName -OnlyDisabledAutoUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"login"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, enabled, @{N="ou"; E={"AUTO DISABLED USERS"}}, @{N="departmentShort"; E={$_.extensionAttribute6}}, @{N="departmentAdditional"; E={$_.extensionAttribute4}}, @{N="office"; E={$_.physicalDeliveryOfficeName}}
$adUsers += D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "skole.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,department,company -OnlyDisabledAutoUsers | Select-Object userPrincipalName, samAccountName, givenName, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"skole"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, enabled, @{N="ou"; E={"AUTO DISABLED USERS"}}, @{N="departmentShort"; E={$_.department}}, @{N="office"; E={$_.company}}

# connect to MONGO
Connect-Mdbc -ConnectionString $db.connectionString -DatabaseName $db.dbName -CollectionName $db.dbCollection

# purge all users from $db.dbName
Remove-MdbcData -Many -Filter "{}"

# add all users to MONGO
$adUsers | Add-MdbcData