param (
    [Parameter(ValueFromPipeline)]
    $obj
)

process {
    $obj.PsObject.Properties | ForEach-Object {
        if($_.Value -is [System.DateTime]) {
            $obj."$($_.Name)" = Get-Date $_.Value -Format o
        } elseif ($_.Value -is [System.Int64] -and $_.Value -gt 94354812000000000) { # Greater than 01.01.1900
            $obj."$($_.Name)" = Get-Date ([DateTime]::FromFileTime($_.Value)) -Format o
        }
    }

    return $obj
}
