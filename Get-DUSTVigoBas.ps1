param(
    [Parameter()]
    [string]$TaskName = "FullRunVigoBas"
)

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$lastRunDate = Get-ChildItem -Path $vigoBas.autoRun -Directory | Select-Object -First 1 | Select-Object @{N="lastRunTime"; E={$_.LastWriteTime}} | .\Fix-Properties.ps1 | ConvertTo-Json

if (!$lastRunDate) {
    return "[]"
}

$lastRunDate