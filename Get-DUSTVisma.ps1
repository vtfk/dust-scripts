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

# import visma functions
$vismaLibs = Join-Path -Path $PSScriptRoot -ChildPath "lib\visma" | Get-ChildItem -Filter "*.ps1"
$vismaLibs | ForEach-Object { . $_.FullName }

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

$json.person | Start-SanitizeVismaData | .\Fix-Properties.ps1 | ConvertTo-Json -Depth 20