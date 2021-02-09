param(
    [Parameter()]
    [string]$SamAccountName,

    [Parameter()]
    [string[]]$Properties = @('displayName', 'distinguishedName', 'enabled', 'passwordLastSet', 'lastLogonDate', 'whenChanged', 'whenCreated', 'eduPersonAffiliation', 'eduPersonEntitlement', 'eduPersonOrgUnitDN', 'norEduPersonAuthnMethod')
)

if (!$SamAccountName) {
    Write-Error -Message "Missing required parameter: 'SamAccountName'" -ErrorAction Stop
}

# default properties that must be present!
@('distinguishedName', 'enabled', 'GivenName', 'Name', 'Surname', 'UserPrincipalName', 'displayName', 'employeeNumber', 'company', 'department', 'passwordLastSet', 'whenChanged', 'whenCreated', 'eduPersonAffiliation', 'eduPersonEntitlement', 'eduPersonOrgUnitDN', 'norEduPersonAuthnMethod') | ForEach-Object {
    if (!$Properties.ToLower().Contains($_.ToLower())) {
        $Properties += $_
    }
}

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$user = Get-ADUser -Filter { Name -eq $SamAccountName } -Server $feide.server -SearchBase $feide.searchBase -Properties $Properties | Select-Object $Properties
if(!$user) {
    Write-Error -Message "No user was found! :(" -ErrorAction Stop
}

return $user | .\Fix-Properties.ps1 | ConvertTo-Json -Depth 20
