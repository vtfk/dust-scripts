$envPath = Join-Path -Path $PSScriptRoot -ChildPath "..\envs.ps1"
. $envPath

$scriptName = "DUSTDBUsers"
$folder = "$($idm.autoRun)\$scriptName"
$script = Get-ChildItem -Path "$PSScriptRoot\*" -Include "Update*.ps1" | Select -First 1 | Select -ExpandProperty FullName

$items = Get-ChildItem $folder
if($items.Count -eq 0)
{
    Write-Host "Nothing todo!" -ForegroundColor Green -BackgroundColor Magenta
    return
}

# delete autorun items
$items | Remove-Item -Force

# run $scriptName script
Write-Host "Running $scriptName script!" -ForegroundColor Green -BackgroundColor Magenta
Start-Process powershell -ArgumentList "-NoLogo -ExecutionPolicy Bypass -File $script" -Wait