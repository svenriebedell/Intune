﻿<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.0
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

<#
.Synopsis
   This PowerShell checking Microsoft Event for the Dell Trusted Device Secure Score and than if the IoA Indicators of attack is not fail.
   IMPORTANT: Need to install Dell Trusted Device first Version 3.2 or newer
   IMPORTANT: This script does not reboot the system to apply or query system.  (Put in any reboot requirements if applicable here)
.DESCRIPTION
   PowerShell to import as Dection Script for Microsoft Endpoint Manager. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for detection only and new a seperate script for remediation.
   
#>

try{
    # Check if Safe BIOS IOA is failed
    $SelectLastLog = Get-EventLog -LogName Dell -InstanceId 15 -Newest 1 | select -ExpandProperty message
    $SelectIOA = ($SelectLastLog.Split([Environment]::newline) | Select-String 'Indicators of Attack')
    $CheckIOA = ($SelectIOA.Line).Split(' ')

    if ($CheckIOA -match "True")
        {
        write-host "Success"
    	exit 0  
        }
    Else
        {
        Write-Host "Missing BIOS Settings"
        exit 1
        }
    }
catch
{
    $errMsg = $_.Exception.Message
    write-host $errMsg
    exit 1
}