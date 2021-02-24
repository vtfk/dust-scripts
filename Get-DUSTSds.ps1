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
    Write-Error -Message "Missing required parameter: 'Type' !" -ErrorAction Stop
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

    if ($sds.server -ne ".") {
        return Invoke-Command -ComputerName $sds.server -ScriptBlock { return Import-Csv -Path "$($Using:sds.folderPath)\$Using:File" -Delimiter $Using:sds.delimiter -Encoding UTF8 | Where-Object { $_.$Using:Header -eq $Using:Value } }
    }
    else {
        return Import-Csv -Path "$($sds.folderPath)\$File" -Delimiter $sds.delimiter -Encoding UTF8 | Where-Object { $_.$Header -eq $Value }
    }
}

Function Get-SdsEnrollmentData {
    param(
        [Parameter(Mandatory = $True)]
        $Person
    )

    return $Person | ForEach-Object {
        $personSchool = $_."School SIS ID"
        $obj = @{
            person = @{
                samAccountName = $_."SIS ID"
                schoolId = $_."School SIS ID"
                userPrincipalName = $_.Username
                type = $Type
            }
        }
        # get enrollment
        if ($Type -eq "Student") {
            $enrollments = Get-SdsData -File "StudentEnrollment.csv" -Header $enrollmentsHeader -Value $_."SIS ID" | Where-Object { $_."Section SIS ID" -match $personSchool }
        }
        elseif ($Type -eq "Teacher") {
            $enrollments = Get-SdsData -File "TeacherRoster.csv" -Header $enrollmentsHeader -Value $_."SIS ID" | Where-Object { $_."Section SIS ID" -match $personSchool }
        }
        
        if (!$enrollments) {
            Write-Warning -Message "$($_."SIS ID") has no enrollments !" -WarningAction SilentlyContinue
            $obj.Add("enrollments", @())
        }
        else {
            $obj.Add("enrollments", $enrollments)
        }
        
        return $obj
    }
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
    Write-Error -Message "Missing required parameter: 'SamAccountName' or 'UserPrincipalName' !" -ErrorAction Stop
}

# get person
$person = Get-SdsData -File $personFile -Header $personHeader -Value $personValue
if (!$person) {
    # Person not found in $personFile
    return "[]"
}
elseif (!$person.Count) {
    $person = @($person)
}

# return persons
return $person | ForEach-Object {
    $result = Get-SdsEnrollmentData -Person $_
    return @{
        person = $result.person
        enrollments = $result.enrollments | ForEach-Object {
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
    }
} | ConvertTo-Json -Depth 20