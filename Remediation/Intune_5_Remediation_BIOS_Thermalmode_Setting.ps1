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

1.0.0   initial version


#>

<#
.Synopsis
   This PowerShell is for remediation by MS Endpoint Manager. This script will set BIOS Thermal Management to "Quiet" on a Dell machine by using WMI.
   IMPORTANT: WMI BIOS is supported only on devices which developt after 2018, older devices does not supported by this powershell
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   Powershell using WMI for setting ThermalManagement on the machine. The script checking if any PW is exist and handover the right credentials to WMI for BIOS setting or if AdminPW is not set it make a simple BIOS setting without credentials. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for remediation only and need a seperate script for detection.
   
#>


# Control check by WMI
$CheckAdminPW = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject -Filter "NameId='Admin'" | select -ExpandProperty IsPasswordSet

#Connect to the BIOSAttributeInterface WMI class
$BAI = Get-WmiObject -Namespace root/dcim/sysman/biosattributes -Class BIOSAttributeInterface

if ($CheckAdminPW -eq 0)
    {
    
    # set FastBoot Thorough by WMI
    $BAI.SetAttribute(0,0,0,"ThermalManagement","Quiet")
    
    Exit 0

    }

Else
    {
    
    # Select AdminPW for this device
    $PWKey = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Dell\BIOS\' -Name BIOS | select -ExpandProperty BIOS
    $serviceTag = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Dell\BIOS\' -Name ServiceTag | select -ExpandProperty ServiceTag
    $AdminPw = "$serviceTag$PWKey"

    # Encoding BIOS Password
    $Encoder = New-Object System.Text.UTF8Encoding
    $Bytes = $Encoder.GetBytes($AdminPw)


    # set FastBoot Thorough by WMI with AdminPW authorization
    $BAI.SetAttribute(1,$Bytes.Length,$Bytes,"ThermalManagement","Quiet")

    Exit 0

    }