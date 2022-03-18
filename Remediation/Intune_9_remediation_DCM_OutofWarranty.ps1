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


# Time popup is closing
$PopupTime = 20 #time in sec.

<#
# prepare Dell Warranty date for compare with actual date
$WarrantyEnd = Get-CimInstance -Namespace root\dcim\sysman -ClassName DCIM_AssetWarrantyInformation | Sort-Object -Descending | select -ExpandProperty WarrantyEndDate 
$WarrantyEndSelect = $WarrantyEnd[0] -split ","
$WarrantyDate = $WarrantyEndSelect -split " "
[datetime]$FinalDate = $WarrantyDate.GetValue(0)

# Check availible support days
$Today = Get-Date
$Duration = New-TimeSpan -Start $Today -End $FinalDate
#>

$Duration = 50

#Checking warranty and inform user 45 days before out of warranty and out of warrenty

If ($Duration -le 45)
    {

    #setup a registrykey to control user has read this information
    New-Item -path "HKLM:\SOFTWARE\Dell\Warranty" -Force


    If ($Duration -le 0)
        {
        
        #creating object os WScript
        $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
        #invoking the POP method using object
        $CheckUserFeedback = $wshell.Popup("This Device is since $Duration Days of of Service. Please, you should open a ServiceNow case to get a new device. If you ignore this message your device will deactivate soon.",$PopupTime,"Device Out of Warranty",64)

        If ($CheckUserFeedback -notmatch 1)
            {

            New-ItemProperty -Path "HKLM:\SOFTWARE\Dell\Warranty" -Name "Info" -Value "no confirmation" -type string -Force
            Write-Output "Device has no support and user ignored message"
            exit 1

            }
        
        Else
            {

            New-ItemProperty -Path "HKLM:\SOFTWARE\Dell\Warranty" -Name "Info" -Value "Informed" -type string -Force
            Write-Output "Device has no support and user is informed"
            exit 0

            }
        }
    Else
        {

        #creating object os WScript
        $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
        #invoking the POP method using object
        $CheckUserFeedback = $wshell.Popup("This Device will be out of service in $Duration Days. Please, you should open a ServiceNow case to get a new device. If you ignore this message your device will deactivate soon.",$PopupTime,"Device Out of Warranty",64)

        If ($CheckUserFeedback -notmatch 1)
            {

            New-ItemProperty -Path "HKLM:\SOFTWARE\Dell\Warranty" -Name "Info" -Value "no confirmation" -type string -Force
            Write-Output "Device has less than 45 days of support and user ignored message"
            exit 1

            }
        
        Else
            {

            New-ItemProperty -Path "HKLM:\SOFTWARE\Dell\Warranty" -Name "Info" -Value "Informed" -type string -Force
            Write-Output "Device has less than 45 days of support and user is informed"
            exit 0

            }
        }  

    }
    
Else
    {

    Write-Output "Device has more than 45 days of support"
    exit 0
                
    }
    