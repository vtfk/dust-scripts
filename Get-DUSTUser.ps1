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
    [string[]]$Properties = @('givenName','sn','displayName','employeeNumber','extensionAttribute6','company','department')
)

# default properties that must be present!
@('DistinguishedName', 'Enabled', 'GivenName', 'Name', 'SamAccountName', 'sn', 'UserPrincipalName', 'displayName', 'employeeNumber','extensionAttribute6','company','department') | % {
    if (!$Properties.ToLower().Contains($_.ToLower())) {
        $Properties += $_
    }
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

if (!$Domain) {
    Write-Error -Message "Domain parameter is required!" -ErrorAction Stop
}

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$searchBase = $ad.baseUnit.Replace("%domain%", $Domain)

$autoUsers = Get-ADUser -SearchBase "$($ad.autoUsers),$searchBase" -Server $domain -Filter $filter -Properties $Properties | Select ($Properties | Sort-Object)
$autoDisabledUsers = Get-ADUser -SearchBase "$($ad.disabledUsers),$searchBase" -Server $domain -Filter $filter -Properties $Properties | Select ($Properties | Sort-Object)

if ($autoUsers) {
    if ($autoDisabledUsers) {
        return ($autoUsers + $autoDisabledUsers) | ConvertTo-Json
    }

    return $autoUsers | ConvertTo-Json
}
elseif ($autoDisabledUsers) {
    return $autoDisabledUsers | ConvertTo-Json
}