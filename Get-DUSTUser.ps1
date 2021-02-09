param(
    [Parameter(ParameterSetName = "SAM")]
    [string]$SamAccountName,

    [Parameter(ParameterSetName = "UPN")]
    [string]$UserPrincipalName,

    [Parameter(ParameterSetName = "SSN")]
    [string]$EmployeeNumber,

    [Parameter(ParameterSetName = "DisplayName")]
    [string]$DisplayName,

    [Parameter()]
    [string]$Domain,

    [Parameter()]
    [string[]]$Properties = @('givenName','sn','displayName','employeeNumber','extensionAttribute6','company','department', 'pwdLastSet')
)

if (!$Domain) {
    Write-Error -Message "Missing required parameter: 'Domain'" -ErrorAction Stop
}

if ($SamAccountName) {
    $filter = "samAccountName -eq '$SamAccountName'"
}
elseif ($UserPrincipalName) {
    $filter = "UserPrincipalName -eq '$UserPrincipalName'"
}
elseif ($EmployeeNumber) {
    $filter = "employeeNumber -eq '$EmployeeNumber'"
}
elseif ($DisplayName) {
    $filter = "DisplayName -like '$DisplayName'"
}
else {
    Write-Error -Message "One of these parameters must be present: 'SamAccountName' , 'UserPrincipalName' , 'EmployeeNumber' , 'DisplayName' !" -ErrorAction Stop
}

# default properties that must be present!
@('DistinguishedName', 'Enabled', 'GivenName', 'Name', 'SamAccountName', 'sn', 'UserPrincipalName', 'displayName', 'employeeNumber', 'extensionAttribute6', 'company', 'department', 'pwdLastSet', 'whenChanged', 'whenCreated') | ForEach-Object {
    if (!$Properties.ToLower().Contains($_.ToLower())) {
        $Properties += $_
    }
}

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$searchBase = $ad.baseUnit.Replace("%domain%", $Domain)

$autoUsers = Get-ADUser -SearchBase "$($ad.autoUsers),$searchBase" -Server $domain -Filter $filter -Properties $Properties | Select-Object ($Properties | Sort-Object)
$autoDisabledUsers = Get-ADUser -SearchBase "$($ad.disabledUsers),$searchBase" -Server $domain -Filter $filter -Properties $Properties | Select-Object ($Properties | Sort-Object)

if ($autoUsers) {
    if ($autoDisabledUsers) {
        return ($autoUsers + $autoDisabledUsers) | .\ConvertTo-DustJson.ps1 | ConvertTo-Json -Depth 20
    }

    return $autoUsers | .\ConvertTo-DustJson.ps1 | ConvertTo-Json -Depth 20
}
elseif ($autoDisabledUsers) {
    return $autoDisabledUsers | .\ConvertTo-DustJson.ps1 | ConvertTo-Json -Depth 20
}
else {
    Write-Error -Message "No user was found! :("
}