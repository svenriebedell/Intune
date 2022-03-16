# prepare Dell Warranty date for compare with actual date
$WarrantyEnd = Get-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_AssetWarrantyInformation | Sort-Object -Descending | select -ExpandProperty WarrantyEndDate 
$WarrantyEndSelect = $WarrantyEnd[0] -split ","
$WarrantyDate = $WarrantyEndSelect -split " "
[datetime]$FinalDate = $WarrantyDate.GetValue(0)

# Check availible support days
$Today = Get-Date
$Duration = New-TimeSpan -Start $Today -End $FinalDate
$last30Days = New-TimeSpan -Start $Today -End $FinalDate.AddDays(-30)


$hash = @{ Support = $Duration.Days; Last30Days = $last30Days.Days }

return $hash | ConvertTo-Json -Compress