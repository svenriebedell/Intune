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


<#
.Synopsis
   This PowerShell is checking by Dell Command Update if the device as any missing driver for severity level Security or critical
   IMPORTANT: Dell Command Update Universal App is need to install first. https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   PowerShell to import as Dection Script for Microsoft Endpoint Manager. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for detection only and need a seperate script for remediation additional.
   
#>

try{
    
    # Check if device have Security or Critcal missing drivers

    cd 'C:\Program Files\Dell\CommandUpdate'
    $UpdateCheck = .\dcu-cli.exe /scan -updateSeverity='Security,Critical' | Select-String "Number of applicable updates for the current system configuration: "
    $UpdateCount = $UpdateCheck.Line.TrimStart('Number of applicable updates for the current system configuration: ')
    
    if ($UpdateCount -eq 0)
        {
        write-host "Success"
    	exit 0  
        }
    Else
        {
        Write-Host "Missing critical drivers"
        exit 1
        }
    }
catch
{
    $errMsg = $_.Exception.Message
    write-host $errMsg
    exit 1
}