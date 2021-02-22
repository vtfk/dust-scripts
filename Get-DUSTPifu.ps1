param(
    [Parameter()]
    [string]$EmployeeNumber
)

# set UTF-8 as output encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (!$EmployeeNumber) {
    Write-Error -Message "Missing required parameter: 'EmployeeNumber'" -ErrorAction Stop
}

try {
    $pifu = Invoke-Expression -Command "node .\node\get-dust-pifu.js $EmployeeNumber"
}
catch {
    Write-Error -Message "Failed to retrieve PIFU file" -ErrorAction Stop
}

if ($pifu -like "ERROR:*") {
    $pifu = $pifu.Replace("ERROR: ", "")
    Write-Error -Message $pifu -ErrorAction Stop
}

$pifu