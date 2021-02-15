param(
    [Parameter(ParameterSetName = "SAM")]
    [string]$SamAccountName,

    [Parameter(ParameterSetName = "UPN")]
    [string]$UserPrincipalName,

    [Parameter()]
    [ValidateSet("Student", "Teacher")]
    [string]$Type
)

if (!$Type) {
    Write-Error -Message "Missing required parameter: 'Type'" -ErrorAction Stop
}

Function Get-SdsData {
    param(
        [Parameter(Mandatory = $True)]
        [string]$File,

        [Parameter(Mandatory = $True)]
        [string]$Header,

        [Parameter(Mandatory = $True)]
        [string]$Value
    )

    return Invoke-Command -ComputerName $sds.server -ScriptBlock { return Import-Csv -Path "$($Using:sds.folderPath)\$Using:File" -Delimiter $Using:sds.delimiter -Encoding UTF8 | Where-Object { $_.$Using:Header -eq $Using:Value } }
}

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

# default variables
$personFile = "$Type.csv"
$enrollmentsHeader = "SIS ID"

if ($SamAccountName) {
    $personHeader = "SIS ID"
    $personValue = $SamAccountName
}
elseif ($UserPrincipalName) {
    $personHeader = "Username"
    $personValue = $UserPrincipalName
}
else {
    Write-Error -Message "One of these parameters must be present: 'SamAccountName' , 'UserPrincipalName' !" -ErrorAction Stop
}

# get person
$person = Get-SdsData -File $personFile -Header $personHeader -Value $personValue
if (!$person) {
    Write-Error -Message "Person not found in $personFile !" -ErrorAction Stop
}

# get enrollment
if ($Type -eq "Student") {
    $enrollments = Get-SdsData -File "StudentEnrollment.csv" -Header $enrollmentsHeader -Value $person."SIS ID"
}
elseif ($Type -eq "Teacher") {
    $enrollments = Get-SdsData -File "TeacherRoster.csv" -Header $enrollmentsHeader -Value $person."SIS ID"
}
if (!$enrollments) {
    Write-Error -Message "Person has no enrollments !" -ErrorAction Stop
}

# return json with section enrollments
return @{
    person = @{
        samAccountName = $person."SIS ID"
        schoolId = $person."School SIS ID"
        userPrincipalName = $person.Username
    }
    enrollments = $enrollments | ForEach-Object {
        # get section
        $section = Get-SdsData -File "Section.csv" -Header "SIS ID" -Value $_."Section SIS ID"
        if (!$section) {
            Write-Warning "Section not found for $($_."Section SIS ID")" -WarningAction SilentlyContinue
            return @{
                sectionId = $_."Section SIS ID"
                schoolId = ""
                sectionName = ""
                sectionCourseDescription = ""
            }
        }
        else {
            return @{
                sectionId = $_."Section SIS ID"
                schoolId = $section."School SIS ID"
                sectionName = $section."Section Name"
                sectionCourseDescription = $section."Course Description"
            }
        }
    }
} | ConvertTo-Json -Depth 20