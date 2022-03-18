<#
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
   This PowerShell is for detection and is checking the support contract time of this device by Dell Command Monitor (DCM).
   IMPORTANT: This scipt need a client installation of Dell Command Monitor https://www.dell.com/support/kbdoc/en-us/000177080/dell-command-monitor
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   Powershell using Dell Command Monitor WMI to check the support contract time if less than 45 days of this device. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for detection only and need a seperate script for remediation additional.
   
#>


# prepare Dell Warranty date for compare with actual date
$WarrantyEnd = Get-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_AssetWarrantyInformation | Sort-Object -Descending | select -ExpandProperty WarrantyEndDate 
$WarrantyEndSelect = $WarrantyEnd[0] -split ","
$WarrantyDate = $WarrantyEndSelect -split " "
[datetime]$FinalDate = $WarrantyDate.GetValue(0)




# Check availible support days
$Today = Get-Date
$Duration = New-TimeSpan -Start $Today -End $FinalDate


#Check if the registry for Warranty Status still exit
$CheckReg = Test-Path -path "HKLM:\SOFTWARE\Dell\Warranty"

If ($CheckReg -match "True")
    {

    #if Registry exit checking value of property Warrant
    $CheckStatus = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\Dell\Warranty -Name Info
    Write-Host "Registry Value requested"

    If ($CheckStatus -match "OutofWarranty")
        {

        Write-Host "Device is out of support and user was informed"
        exit 0

        }
    Else
        {

        if ($Duration -le 0)
            {

            Write-Host "Device has no support anymore"
            Exit 1

            }
        Else
            {

            Write-Output "Device is running out of support and user is informed"
            Exit 0
            
            }
        }

    }
Else
    {

    If ($Duration -ge 45)
        {

        Write-Host "Device has more than 45 days of support"
        exit 0
        
        }
    Else
        {

        Write-Host "Device has less than 45 days of support"
        exit 1

        }

  
    }
    
    