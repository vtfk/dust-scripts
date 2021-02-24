param(
    [Parameter()]
    [string]$EmployeeNumber
)

# set UTF-8 as output encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (!$EmployeeNumber) {
    Write-Error -Message "Missing required parameter: 'EmployeeNumber'" -ErrorAction Stop
}

$currentLocation = Get-Location | Select-Object -ExpandProperty Path
$nodePath = Join-Path -Path $PSScriptRoot -ChildPath "node"

try {
    Set-Location -Path $nodePath
    $pifu = Invoke-Expression -Command "node .\get-dust-pifu.js $EmployeeNumber" -ErrorAction Stop
    Set-Location -Path $currentLocation
}
catch {
    Write-Error -Message "Failed to retrieve PIFU file: $_" -ErrorAction Stop
}

$pifu