<##
.DESCRIPTION
    This will remove sections that should not be viewed by everyone
#>
Function Start-SanitizeVismaData {
    param(
        [Parameter(ValueFromPipeline)]
        $CustomObj
    )

    process {
        @('dependents', 'maritalStatus', 'socialSecurityOffice') | ForEach-Object {
            $CustomObj = Remove-VismaProperty -Obj $CustomObj -Name $_
        }

        if ($CustomObj.employments -and $CustomObj.employments.employment) {
            if ($CustomObj.employments.employment.Count) {
                # multiple employments
                for ($i = 0; $i -lt $CustomObj.employments.employment.Count; $i++) {
                    $CustomObj.employments.employment[$i] = Start-SanitizeVismaEmployment -Employment $CustomObj.employments.employment[$i]
                }
            }
            else {
                # one employment
                $CustomObj.employments.employment = Start-SanitizeVismaEmployment -Employment $CustomObj.employments.employment
            }
        }

        return $CustomObj
    }
}