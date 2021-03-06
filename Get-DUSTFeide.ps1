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
    [string[]]$Properties = @('')
)

if ($SamAccountName) {
    $filter = "Name -eq '$SamAccountName'"
}
elseif ($UserPrincipalName) {
    $filter = "mail -eq '$UserPrincipalName'"
}
elseif ($EmployeeNumber) {
    $filter = "norEduPersonNIN -eq '$EmployeeNumber'"
}
elseif ($DisplayName) {
    $filter = "DisplayName -like '$DisplayName'"
}
else {
    Write-Error -Message "Missing required parameter: 'SamAccountName' or 'UserPrincipalName' or 'EmployeeNumber' or 'DisplayName' !" -ErrorAction Stop
}

# default properties that must be present!
@('distinguishedName', 'enabled', 'givenName', 'name', 'surname', 'mail', 'displayName', 'norEduPersonNIN', 'passwordLastSet', 'lastLogonDate', 'whenChanged', 'whenCreated', 'eduPersonAffiliation', 'eduPersonEntitlement', 'eduPersonOrgUnitDN', 'norEduPersonAuthnMethod', 'norEduPersonNIN', 'eduPersonOrgDN', 'uid', 'eduPersonPrincipalName', 'lockedOut') | ForEach-Object {
    if (!$Properties.ToLower().Contains($_.ToLower())) {
        $Properties += $_
    }
}

# remove the empty item (workaround to be able to use .ToLower() on an array)
$Properties = $Properties | Where-Object { ![string]::IsNullOrEmpty($_) }

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$user = Get-ADUser -Filter $filter -Server $feide.server -SearchBase $feide.searchBase -Properties $Properties | Select-Object ($Properties | Sort-Object)
if(!$user) {
    # No user was found! :(
    return "[]"
}

return $user | .\Fix-Properties.ps1 | ConvertTo-Json -Depth 20