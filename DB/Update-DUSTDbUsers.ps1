$adUsers = @()

# get ad users from AUTO USERS
$adUsers += D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "login.top.no" -Filter "*" -Properties memberOf,givenName,sn,displayName,employeeNumber,extensionAttribute4,extensionAttribute6,extensionAttribute7,company,physicalDeliveryOfficeName,mail,proxyAddresses,title,state -OnlyAutoUsers | Select-Object userPrincipalName, samAccountName, givenName, mail, proxyAddresses, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"login"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, enabled, @{N="ou"; E={"AUTO USERS"}}, extensionAttribute7, @{N="departmentShort"; E={$_.extensionAttribute6}}, @{N="departmentAdditional"; E={$_.extensionAttribute4}}, @{N="office"; E={$_.physicalDeliveryOfficeName}}, @{N="company"; E={$_.company}}, title, state, @{N="feide"; E={if ($_.memberOf -like "*VT-ALLE-LÆRERE*") {$True} else {$False}}}
$adUsers += D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "skole.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,department,company,mail,proxyAddresses -OnlyAutoUsers | Select-Object userPrincipalName, samAccountName, givenName, mail, proxyAddresses, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"skole"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, enabled, @{N="ou"; E={"AUTO USERS"}}, @{N="departmentShort"; E={$_.department}}, @{N="office"; E={$_.company}}, @{N="company"; E={$_.company}}

# get ad users from AUTO DISABLED USERS
$adUsers += D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "login.top.no" -Filter "*" -Properties memberOf,givenName,sn,displayName,employeeNumber,extensionAttribute4,extensionAttribute6,extensionAttribute7,company,physicalDeliveryOfficeName,mail,proxyAddresses,title,state -OnlyDisabledAutoUsers | Select-Object userPrincipalName, samAccountName, givenName, mail, proxyAddresses, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"login"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, enabled, @{N="ou"; E={"AUTO DISABLED USERS"}}, extensionAttribute7, @{N="departmentShort"; E={$_.extensionAttribute6}}, @{N="departmentAdditional"; E={$_.extensionAttribute4}}, @{N="office"; E={$_.physicalDeliveryOfficeName}}, @{N="company"; E={$_.company}}, title, state, @{N="feide"; E={if ($_.memberOf -like "*VT-ALLE-LÆRERE*") {$True} else {$False}}}
$adUsers += D:\Scripts\VTFK-Toolbox\AD\Get-VTFKADUser.ps1 -Domain "skole.top.no" -Filter "*" -Properties givenName,sn,displayName,employeeNumber,department,company,mail,proxyAddresses -OnlyDisabledAutoUsers | Select-Object userPrincipalName, samAccountName, givenName, mail, proxyAddresses, @{N="surName"; E={$_.sn}}, displayName, @{N="domain"; E={"skole"}}, employeeNumber, @{N="timestamp"; E={Get-Date -Format o}}, enabled, @{N="ou"; E={"AUTO DISABLED USERS"}}, @{N="departmentShort"; E={$_.department}}, @{N="office"; E={$_.company}}, @{N="company"; E={$_.company}}

# db-update folder path
$dbUpdateFolder = Resolve-Path -Path "$($PSScriptRoot)\..\node\db-update" | Select-Object -ExpandProperty Path

# export users
$exportFile = "$dbUpdateFolder\data\users.json"
$adUsers | ConvertTo-Json -Depth 20 | Out-File -FilePath $exportFile -Encoding utf8 -Force -NoNewline

# update db
$currentLocation = Get-Location | Select-Object -ExpandProperty Path
try {
    Set-Location -Path $dbUpdateFolder
    Invoke-Expression -Command "node .\index.js" -ErrorAction Stop
}
catch {
    Write-Error -Message "Failed to update DUST users DB : $_" -ErrorAction Stop
}
finally {
    Set-Location -Path $currentLocation
}