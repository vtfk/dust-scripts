param(
    [Parameter()]
    [string]$SamAccountName
)

Function Get-EquiTrackUser {
    $output = Invoke-Expression -Command "$($equiTrack.path) -s$($equiTrack.server) query ur $SamAccountName"
    return Get-EquiTrackObject -Output $output -Type Query
}

Function Unlock-EquiTrackUser {
    $output = Invoke-Expression -Command "$($equiTrack.path) -s$($equiTrack.server) unlock ur $SamAccountName"
    return Get-EquiTrackObject -Output $output -Type Unlock
}

Function Get-EquiTrackObject {
    param(
        [Parameter(Mandatory = $True)]
        $Output,

        [Parameter(Mandatory = $True)]
        [ValidateSet("Query", "Lock", "Unlock")]
        [string]$Type
    )

    if ($Type -eq "Query") {
        $headers = ConvertTo-String -Chars $Output[0].ToCharArray() | Remove-Empty
        if ($headers -like "*Can't find the specified account in database*") {
            return ""
        }
        $body = ConvertTo-String -Chars $Output[2].ToCharArray() | Remove-Empty

        $obj = @{}

        for ($i = 0; $i -lt $headers.Length; $i++) {
            $obj.Add($headers[$i].Replace("_", ""), $body[$i])
        }

        return $obj
    }
    elseif ($Type -eq "Lock" -or $Type -eq "Unlock") {
        return ConvertTo-String -Chars $Output[0].ToCharArray() | Remove-Empty
    }
    else {
        return ""
    }
}

Function ConvertTo-String {
    param(
        [Parameter(Mandatory = $True)]
        [char[]]$Chars
    )

    [string]$output = ""
    $Chars | ForEach-Object {
        if ([int]$_ -gt 0) { $output += $_ }
    }
    return $output
}

Function Remove-Empty {
    param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [string[]]$Strings
    )

    return $Strings.Split("`"") | % { $trimmed = $_.Trim(); if ($trimmed -ne "") { $trimmed } }
}

# import environment variables
$envPath = Join-Path -Path $PSScriptRoot -ChildPath "envs.ps1"
. $envPath

if (!$SamAccountName) {
    Write-Error -Message "Missing required parameter: 'SamAccountName' !" -ErrorAction Stop
}
if (!(Test-Path -Path $equiTrack.path)) {
    Write-Error -Message "Missing required executable 'EQCmd.exe' !" -ErrorAction Stop
}

$user = Get-EquiTrackUser
if (!$user) {
    return "[]"
}
if ($user.AccountStatus -eq "Locked") {
    $unlockUser = Unlock-EquiTrackUser
    if ($unlockUser -like "*successfully*") {
        $user.PreviousAccountStatus = $user.AccountStatus
        $user.AccountStatus = "Unlocked"
    }
}

$user | ConvertTo-Json -Depth 20