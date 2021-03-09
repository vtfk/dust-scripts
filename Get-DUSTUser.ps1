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
    [ValidateSet("login", "skole")]
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
    Write-Error -Message "Missing required parameter: 'SamAccountName' or 'UserPrincipalName' or 'EmployeeNumber' or 'DisplayName' !" -ErrorAction Stop
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
        return ($autoUsers + $autoDisabledUsers) | .\Fix-Properties.ps1 | ConvertTo-Json -Depth 20
    }

    return $autoUsers | .\Fix-Properties.ps1 | ConvertTo-Json -Depth 20
}
elseif ($autoDisabledUsers) {
    return $autoDisabledUsers | .\Fix-Properties.ps1 | ConvertTo-Json -Depth 20
}
else {
    # No user was found :(
    return "[]"
}