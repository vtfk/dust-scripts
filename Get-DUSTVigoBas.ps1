param(
    [Parameter()]
    [string]$TaskName = "FullRunVigoBas"
)

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$lastRunDate = Invoke-Command -ComputerName $vigoBas.server -ScriptBlock { Get-ChildItem -Path C:\Windows\Logs\AutoRun -Directory | Select-Object -First 1 } | Select-Object @{N="lastWriteTime"; E={$_.LastWriteTime}} | .\Fix-Properties.ps1 | ConvertTo-Json

if (!$lastRunDate) {
    return "[]"
}

$lastRunDate