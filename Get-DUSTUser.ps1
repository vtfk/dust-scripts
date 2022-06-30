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
    [string[]]$Properties = @('')
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
@('distinguishedName', 'enabled', 'givenName', 'name', 'samAccountName', 'sn', 'userPrincipalName', 'displayName', 'employeeNumber', 'extensionAttribute6', 'extensionAttribute4', 'company', 'department', 'pwdLastSet', 'whenChanged', 'whenCreated', 'lockedOut', 'mail', 'proxyAddresses', 'state', 'title', 'memberOf') | ForEach-Object {
    if (!$Properties.ToLower().Contains($_.ToLower())) {
        $Properties += $_
    }
}

# remove the empty item (workaround to be able to use .ToLower() on an array)
$Properties = $Properties | Where-Object { ![string]::IsNullOrEmpty($_) }

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$searchBase = $ad.baseUnit.Replace("%domain%", $Domain)

$users = Get-ADUser -SearchBase $searchBase -Server $domain -Filter $filter -Properties $Properties | Select-Object ($Properties | Sort-Object)

if ($users) {
    return $users | .\Fix-Properties.ps1 | ConvertTo-Json -Depth 20
}
else {
    # No user was found :(
    return "[]"
}