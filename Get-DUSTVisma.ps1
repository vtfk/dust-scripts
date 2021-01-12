param(
    [Parameter(ParameterSetName = "SSN")]
    [string]$EmployeeNumber,

    [Parameter(ParameterSetName = "Name")]
    [string]$FirstName,

    [Parameter(ParameterSetName = "Name")]
    [string]$LastName
)

if (!$EmployeeNumber -and (!$FirstName -or !$LastName)) {
    Write-Error "Parameter 'FirstName' and 'LastName' must be filled out!" -ErrorAction Stop
}

<##
    .DESCRIPTION
        This will remove sections that should not be viewed by everyone
#>
Function Start-SanitizeDataData
{
    param(
        [Parameter(ValueFromPipeline)]
        $CustomObj
    )

    process {
        $CustomObj.dependents = $null
        $CustomObj.employments.employment.bankDetails = $null
        
        if ($CustomObj.employments.employment.positions.position.Count) {
            $CustomObj.employments.employment.positions.position | % {
                if ($_.fixedTransactions) {
                    $_.fixedTransactions = $null
                }
                if ($_.salaryInfo) {
                    $_.salaryInfo = $null
                }
            }
        }
        else 
        {
            if ($CustomObj.employments.employment.positions.position.fixedTransactions) {
                $CustomObj.employments.employment.positions.position.fixedTransactions = $null
            }
            if ($CustomObj.employments.employment.positions.position.salaryInfo) {
                $CustomObj.employments.employment.positions.position.salaryInfo = $null
            }
        }
        $CustomObj.employments.employment.taxDetails = $null
        $CustomObj.employments.employment.union = $null

        return $CustomObj
    }
}

# import environment variables
. .\envs.ps1

$credential = New-Object pscredential -ArgumentList $visma.username,(ConvertTo-SecureString -String $visma.password -AsPlainText -Force)

if ($EmployeeNumber) {
    [XML]$result = Invoke-RestMethod -Uri "$($visma.baseUri)/ssn/$EmployeeNumber" -Credential $credential -Method Get
    $json = [Newtonsoft.Json.JsonConvert]::SerializeXmlNode($result) | ConvertFrom-Json
}
else {
    [XML]$result = Invoke-RestMethod -Uri "$($visma.baseUri)/name/firstname/$FirstName/lastname/$LastName" -Credential $credential -Method Get
    $json = [Newtonsoft.Json.JsonConvert]::SerializeXmlNode($result.personsXML) | ConvertFrom-Json | Select -ExpandProperty personsXML
}

if (!$json.person) {
    return "[]"
}

$json.person | Start-SanitizeDataData | ConvertTo-Json -Depth 20