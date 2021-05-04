Function Remove-VismaProperty {
    param(
        [Parameter()]
        $Obj,

        [Parameter()]
        [string]$Name
    )

    if ($Obj.PSObject.Properties[$Name]) {
        $Obj.PSObject.Properties.Remove($Name)
    }

    return $Obj
}