﻿<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.0.0
_Dev_Status_ = Test
Copyright © 2022 Dell Inc. or its subsidiaries. All Rights Reserved.

No implied support and test in test environment/device before using in any production environment.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

<#Version Changes

1.0.0   inital version


#>

<#
.Synopsis
   This PowerShell is for remediation and is checking the support contract time of this device by Dell Command Monitor (DCM) and User will informed by popup to order a new device. User need to click ok otherwise he will informed again.
   IMPORTANT: This scipt need a client installation of Dell Command Monitor https://www.dell.com/support/kbdoc/en-us/000177080/dell-command-monitor
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   Powershell using Dell Command Monitor WMI to check the support contract time of the device. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for remediation only and need a seperate script for detection additional.
   
#>


# prepare Dell Warranty date for compare with actual date
$WarrantyEnd = Get-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_AssetWarrantyInformation | Sort-Object -Descending | select -ExpandProperty WarrantyEndDate 
$WarrantyEndSelect = $WarrantyEnd[0] -split ","
$WarrantyDate = $WarrantyEndSelect -split " "
[datetime]$FinalDate = $WarrantyDate.GetValue(0)

# Check availible support days
$Today = Get-Date
$Duration = New-TimeSpan -Start $Today -End $FinalDate

#Checking warranty and inform user 45 days before out of warranty and out of warrenty

Test-Path -path "HKLM:\SOFTWARE\Dell\Warranty"

If ($Duration -le 45)
    {

    If ($Duration -le 0)
        {
        
        Write-Host "Device out of Service"
        exit 0

        }
    Else
        {
        
        Write-Output "Device less than 45 days of support"
        exit 0
      
        }
    }
    
Else
    {

    Write-Output "Device has more than 45 days of support"
    exit 0
                
    }

    Test-Path -Path HKLM:\SOFTWARE\DELL\UpdateService\Service\IgnoreList\ -