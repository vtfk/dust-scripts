# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$lastRunDate = Get-ChildItem -Path $idm.autoRun -File -Filter $idm.file | Select-Object @{N="lastRunTime"; E={$_.LastWriteTime}} | .\Fix-Properties.ps1 | ConvertTo-Json

if (!$lastRunDate) {
    return "[]"
}

$lastRunDate