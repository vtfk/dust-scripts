# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$lastRunDate = Invoke-Command -ComputerName $idm.server -ScriptBlock { Get-ScheduledTask -TaskPath "\" | Where-Object { $Using:idm.tasks -contains $_.TaskName } | Get-ScheduledTaskInfo | Sort-Object LastRunTime -Descending | Select-Object -First 1 | Select-Object @{N="lastRunTime"; E={$_.LastRunTime}} }
$lastRunDate = $lastRunDate | Select-Object lastRunTime | .\Fix-Properties.ps1 | ConvertTo-Json

if (!$lastRunDate) {
    return "[]"
}

$lastRunDate