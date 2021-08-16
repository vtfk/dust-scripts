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
        $data = Invoke-Command -ComputerName $sds.server -ScriptBlock { return Import-Csv -Path "$($Using:sds.folderPath)\$Using:File" -Delimiter $Using:sds.delimiter -Encoding UTF8 }
    }
    else {
        $data = Import-Csv -Path "$($sds.folderPath)\$File" -Delimiter $sds.delimiter -Encoding UTF8
    }

    return $data | Where-Object { $_.$Header -eq $Value }
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
            person = [ordered]@{
                samAccountName = $_."SIS ID"
                schoolId = $personSchool
                schoolName = $schools.$personSchool.name
                schoolIdVariants = $schoolIdVariants
                userPrincipalName = $_.Username
                type = $Type
            }
        }
        # get enrollment
        $enrollmentSplat = @{
            Header = $enrollmentsHeader
            Value = $_."SIS ID"
        }
        if ($Type -eq "Student") {
            $enrollmentSplat.Add("File", "StudentEnrollment.csv")
        }
        elseif ($Type -eq "Teacher") {
            $enrollmentSplat.Add("File", "TeacherRoster.csv")
        }
        $enrollments = Get-SdsData @enrollmentSplat | Where-Object { $_."Section SIS ID" -match ($schoolIdVariants -join "|") }
        
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
    "OF-SANV" = @{
        name = "Sande videregående skole"
        variants = @("SVS", "OF-SANV", "SANV")
    }
    "OF-HOLV" = @{
        name = "Holmestrand videregående skole"
        variants = @("HSVS", "HLVS", "OF-HOLV", "HOLV")
    }
    "OF-HORV" = @{
         name = "Horten videregående skole"
         variants = @("HVS", "OF-HORV", "HORV")
    }
    "OF-REV" = @{
         name = "Re videregående skole"
         variants = @("RVS", "OF-REV", "REV")
    }
    "OF-GRV" = @{
         name = "Greveskogen videregående skole"
         variants = @("GVS", "GRVS", "OF-GRV", "GRV")
    }
    "OF-KB" = @{
         name = "Kompetansebyggeren"
         variants = @("KBV", "OF-KB", "KB")
    }
    "OF-FRV" = @{
         name = "Færder videregående skole"
         variants = @("FVS", "FRVS", "OF-FRV", "FRV")
    }
    "OF-NTV" = @{
         name = "Nøtterøy videregående skole"
         variants = @("NVS", "OF-NTV", "NTV")
    }
    "OF-MEV" = @{
         name = "Melsom videregående skole"
         variants = @("MVS", "OF-MEV", "MEV")
    }
    "OF-SFV" = @{
         name = "Sandefjord videregående skole"
         variants = @("SFVS", "SVGS", "OF-SFV", "SFV")
    }
    "OF-THV" = @{
         name = "Thor Heyerdahl videregående skole"
         variants = @("THVS", "OF-THV", "THV")
    }
    "OF-BAV" = @{
         name = "Bamble videregående skole"
         variants = @("BAMVS", "CROVS", "OF-BAV", "BAV")
    }
    "OF-BOV" = @{
         name = "Bø videregående skole"
         variants = @("BOEVS", "OF-BOV", "BOV")
    }
    "OF-HJV" = @{
         name = "Hjalmar Johansen videregående skole"
         variants = @("KLOVS", "OF-HJV", "HJV")
    }
    "OF-KRV" = @{
         name = "Kragerø videregående skole"
         variants = @("KRAVS", "OF-KRV", "KRV")
    }
    "OF-NOMV" = @{
         name = "Nome videregående skole"
         variants = @("NOMVS", "LUNVS", "SOEVS", "OF-NOMV", "NOMV")
    }
    "OF-NOV" = @{
         name = "Notodden videregående skole"
         variants = @("NOTVS", "OF-NOV", "NOV")
    }
    "OF-POV" = @{
         name = "Porsgrunn videregående skole"
         variants = @("PORVS", "OF-POV", "POV")
    }
    "OF-RJV" = @{
         name = "Rjukan videregående skole"
         variants = @("RJUVS", "OF-RJV", "RJV")
    }
    "OF-SKIV" = @{
         name = "Skien videregående skole"
         variants = @("SKIVS", "OF-SKIV", "SKIV")
    }
    "OF-SKOV" = @{
         name = "Skogmo videregående skole"
         variants = @("SKOVS", "OF-SKOV", "SKOV")
    }
    "OF-VTV" = @{
         name = "Vest-Telemark videregående skole"
         variants = @("DALVS", "SELVS", "OF-VTV", "VTV")
    }
    <# TELVS = @{
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
    } #>
    "NIK-FAGS" = @{
         name = "Fagskolen i Vestfold og Telemark"
         variants = @("TELVS", "FIV", "NIK-FAGS")
    }
    "OF-SMI" = @{
         name = "Skolen for sosiale og medisinske institusjoner"
         variants = @("MVS-SMIH", "OF-SMI")
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
                return [ordered]@{
                    sectionId = $_."Section SIS ID"
                    schoolId = ""
                    sectionName = ""
                    sectionCourseDescription = ""
                }
            }
            else {
                return [ordered]@{
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