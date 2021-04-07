param(
    [Parameter(ParameterSetName = "SSN")]
    [string]$EmployeeNumber,

    [Parameter(ParameterSetName = "Name")]
    [string]$GivenName,

    [Parameter(ParameterSetName = "Name")]
    [string]$SurName
)

# make sure Newtonsoft.Json.JsonConvert is accesible, otherwise import it from System32. If not found, script will fail
try {
    [Newtonsoft.Json.JsonConvert] | Out-Null
}
catch {
    try {
        [Reflection.Assembly]::LoadFile("C:\Windows\System32\Newtonsoft.Json.dll") | Out-Null
    }
    catch {
        Write-Error "'Newtonsoft.Json.JsonConvert' not found. Make sure it's installed on the server!" -ErrorAction Stop
    }
}

if (!$EmployeeNumber -and (!$GivenName -or !$SurName)) {
    Write-Error "Missing required parameter 'EmployeeNumber' OR 'GivenName' and 'SurName' !" -ErrorAction Stop
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
        $CustomObj.employments.employment.paymentInAdvance = $null
        $CustomObj.employments.employment.pension = $null
        
        if ($CustomObj.employments.employment.positions.position.Count) {
            $CustomObj.employments.employment.positions.position | ForEach-Object {
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
        
        $CustomObj.employments.employment.statistics = $null
        $CustomObj.employments.employment.taxDetails = $null
        $CustomObj.employments.employment.union = $null

        return $CustomObj
    }
}

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

$credential = New-Object pscredential -ArgumentList $visma.username,(ConvertTo-SecureString -String $visma.password -AsPlainText -Force)

if ($EmployeeNumber) {
    [XML]$result = Invoke-RestMethod -Uri "$($visma.baseUri)/ssn/$EmployeeNumber" -Credential $credential -Method Get
    $json = [Newtonsoft.Json.JsonConvert]::SerializeXmlNode($result) | ConvertFrom-Json
    
    if ([int]$json.person."@personIdHRM" -le 0) {
        return "[]"
    }
}
else {
    [XML]$result = Invoke-RestMethod -Uri "$($visma.baseUri)/name/firstname/$GivenName/lastname/$SurName" -Credential $credential -Method Get
    $json = [Newtonsoft.Json.JsonConvert]::SerializeXmlNode($result.personsXML) | ConvertFrom-Json | Select-Object -ExpandProperty personsXML
    
    if (!$json.person) {
        return "[]"
    }
}

$json.person | Start-SanitizeDataData | .\Fix-Properties.ps1 | ConvertTo-Json -Depth 20