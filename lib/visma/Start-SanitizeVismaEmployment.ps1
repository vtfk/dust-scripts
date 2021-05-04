<##
.DESCRIPTION
    This will remove sections that should not be viewed by everyone
#>
Function Start-SanitizeVismaEmployment {
    param(
        [Parameter()]
        $Employment
    )

    @('bankDetails', 'paymentInAdvance', 'pension', 'statistics', 'taxDetails', 'union') | ForEach-Object {
        $Employment = Remove-VismaProperty -Obj $Employment -Name $_
    }

    if ($Employment.positions -and $Employment.positions.position) {
        if ($Employment.positions.position.Count) {
            # multiple positions
            for ($i = 0; $i -lt $Employment.positions.position.Count; $i++) {
                @('fixedTransactions', 'salaryInfo', 'statistics', 'taxDetails', 'union') | ForEach-Object {
                    $Employment.positions.position[$i] = Remove-VismaProperty -Obj $Employment.positions.position[$i] -Name $_
                }
            }
        }
        else {
            # one position
            @('fixedTransactions', 'salaryInfo', 'statistics', 'taxDetails', 'union') | ForEach-Object {
                $Employment.positions.position = Remove-VismaProperty -Obj $Employment.positions.position -Name $_
            }
        }
    }

    return $Employment
}