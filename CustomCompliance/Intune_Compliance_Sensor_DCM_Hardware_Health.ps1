$BatteryHealth = Switch (Get-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_Battery | Select -ExpandProperty HealthState)
    {
    0 {"Unknown"}
    5 {"OK"}
    10 {"Degraded/Warning"}
    15 {"Minor failure"}
    20 {"Major failure"}
    25 {"Critical failure"}
    30 {"Non-recoverable error"}
    }


$thermal_fan = switch(Get-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_ThermalInformation -Filter "AttributeName='Fan Failure Mode'" | Select -ExpandProperty CurrentValue)
    { 
    0 {"Catastrophic Fan Failure"}
    1 {"Minimal Fan Failure"} 
    2 {"No Failure"}
    }


$hash = @{ BatteryHealth = $BatteryHealth; FanHealth = $thermal_fan }

return $hash | ConvertTo-Json -Compress