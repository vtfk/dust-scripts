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
        $schoolIdVariants = $schools.$personSchool.variants
        $obj = @{
            person = @{
                samAccountName = $_."SIS ID"
                schoolId = $personSchool
                schoolIdVariants = $schoolIdVariants
                userPrincipalName = $_.Username
                type = $Type
            }
        }
        # get enrollment
        if ($Type -eq "Student") {
            $enrollments = Get-SdsData -File "StudentEnrollment.csv" -Header $enrollmentsHeader -Value $_."SIS ID" | Where-Object { $_."Section SIS ID" -match ($schoolIdVariants -join "|") }
        }
        elseif ($Type -eq "Teacher") {
            $enrollments = Get-SdsData -File "TeacherRoster.csv" -Header $enrollmentsHeader -Value $_."SIS ID" | Where-Object { $_."Section SIS ID" -match ($schoolIdVariants -join "|") }
        }
        
        if (!$enrollments) {
            Write-Warning -Message "$($_."SIS ID") has no enrollments on $personSchool !"
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

# translation between old and new school codes
$schools = @{
    SVS = @{
        name = "Sande videregående skole"
        variants = @("SVS")
    }
    HSVS = @{
        name = "Holmestrand videregående skole"
        variants = @("HSVS", "HLVS")
    }
    HVS = @{
         name = "Horten videregående skole"
         variants = @("HVS")
    }
    RVS = @{
         name = "Re videregående skole"
         variants = @("RVS")
    }
    GVS = @{
         name = "Greveskogen videregående skole"
         variants = @("GVS", "GRVS")
    }
    KBV = @{
         name = "Kompetansebyggeren"
         variants = @("KBV")
    }
    FVS = @{
         name = "Færder videregående skole"
         variants = @("FVS", "FRVS")
    }
    NVS = @{
         name = "Nøtterøy videregående skole"
         variants = @("NVS")
    }
    MVS = @{
         name = "Melsom videregående skole"
         variants = @("MVS")
    }
    SFVS = @{
         name = "Sandefjord videregående skole"
         variants = @("SFVS", "SVGS")
    }
    THVS = @{
         name = "Thor Heyerdahl videregående skole"
         variants = @("THVS")
    }
    BAMVS = @{
         name = "Bamble videregående skole"
         variants = @("BAMVS", "CROVS")
    }
    BOEVS = @{
         name = "Bø videregående skole"
         variants = @("BOEVS")
    }
    KLOVS = @{
         name = "Hjalmar Johansen videregående skole"
         variants = @("KLOVS")
    }
    KRAVS = @{
         name = "Kragerø videregående skole"
         variants = @("KRAVS")
    }
    NOMVS = @{
         name = "Nome videregående skole"
         variants = @("NOMVS", "LUNVS", "SOEVS")
    }
    NOTVS = @{
         name = "Notodden videregående skole"
         variants = @("NOTVS")
    }
    PORVS = @{
         name = "Porsgrunn videregående skole"
         variants = @("PORVS")
    }
    RJUVS = @{
         name = "Rjukan videregående skole"
         variants = @("RJUVS")
    }
    SKIVS = @{
         name = "Skien videregående skole"
         variants = @("SKIVS")
    }
    SKOVS = @{
         name = "Skogmo videregående skole"
         variants = @("SKOVS")
    }
    DALVS = @{
         name = "Vest-Telemark videregående skole"
         variants = @("DALVS", "SELVS")
    }
    TELVS = @{
         name = "Telemark fagskole"
         variants = @("TELVS")
    }
    FIV = @{
         name = "Fagskolen i Vestfold"
         variants = @("FIV")
    }
    NETT = @{
         name = "Nettskolen Vestfold"
         variants = @("HVS-NETT")
    }
    "OF-SMI" = @{
         name = "Skolen for sosiale og medisinske institusjoner"
         variants = @("MVS-SMIH")
    }
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
$output = $person | ForEach-Object {
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
}

# workaround to force only one object to also be wrapped in an array
if ($output.GetType().Name -eq "Hashtable") {
    $output = @($output)
}

# workaround to force only one object to also be wrapped in an array
$output | ForEach-Object {
    if ($_.enrollments.GetType().Name -eq "Hashtable") {
        $_.enrollments = @($_.enrollments)
    }
}

# $output can not be piped to ConvertTo-Json since there's a bug in the cmdlet which then will convert arrays with one item into an object instead
return ConvertTo-Json -InputObject $output -Depth 20