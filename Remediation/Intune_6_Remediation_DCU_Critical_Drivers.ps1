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
   This PowerShell is updating critical drivers by Dell Command Update. If the device has any missing driver for severity level Security or critical
   IMPORTANT: Dell Command Update Universal App is need to install first. https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   PowerShell to import as Remediation Script for Microsoft Endpoint Manager. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for Remediation only and need a seperate script for Detection additional. 
#>

# Variable
$PresharedKey = "Dell2022#0123"

# Control check by WMI
$CheckAdminPW = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject -Filter "NameId='Admin'" | select -ExpandProperty IsPasswordSet

#Connect to the BIOSAttributeInterface WMI class
$BAI = Get-WmiObject -Namespace root/dcim/sysman/biosattributes -Class BIOSAttributeInterface

# Change Path
cd 'C:\Program Files\Dell\CommandUpdate' #if you using DCU 32/64 Bit version you need to change the directory to C:\Program Files (x86)\Dell\CommandUpdate


if ($CheckAdminPW -eq 0)
    {
    
    .\dcu-cli.exe /applyUpdates -silent -updateSeverity='Security,Critical' -reboot=disable -autoSuspendBitLocker=enable
        
    }

Else
    {
    
    # Select AdminPW for this device
    $PWKey = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Dell\BIOS\' -Name BIOS | select -ExpandProperty BIOS
    $serviceTag = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Dell\BIOS\' -Name ServiceTag | select -ExpandProperty ServiceTag
    $AdminPw = "$serviceTag$PWKey"

    # generate encrypted BIOS PW
    $BIOSPWEncrypted = .\dcu-cli.exe /generateEncryptedPassword -encryptionKey="$PresharedKey" -password="$AdminPw"

    # start update critical drivers
    .\dcu-cli.exe /applyUpdates -encryptedPassword="$BIOSPWEncrypted" -encryptionKey="$PresharedKey" -silent -updateSeverity='Security,Critical' -reboot=disable -autoSuspendBitLocker=enable
    
    }