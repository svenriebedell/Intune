<#
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
   This PowerShell is checking if all Dell Monitors have ComfortView enabled.
   IMPORTANT: This PowerShell need a installation of Dell Display Manager 32-Bit Version https://www.delldisplaymanager.com/
   IMPORTANT: Dell Display Manager support Dell Displays only
   IMPORTANT: This script does not reboot the system to apply or query system.

.DESCRIPTION
   PowerShell to import as Decetion Script for Microsoft Endpoint Manager. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for detection only and need a seperate script for remediation additional.
#>

try{
    
    #running inventory by Dell Display Manager
    $env:Path ='C:\Program Files (x86)\Dell\Dell Display Manager'
    cd $env:Path
    Start-Process -FilePath "ddm.exe" -ArgumentList "/inventory DCIM" -Wait


    #Check DDM setting for value ColorModePreset
    $CheckColorMode = get-childitem -recurse HKCU:\Software\EnTech\DCIM | get-itemproperty | where { $_  -match 'Dell*' } | Get-ItemPropertyValue -Name ColorModePreset
    
    If ($CheckColorMode -ne $null)
        {

        if ($CheckColorMode -notmatch 4)
            {
        
            write-host "One or more Dell Displays have not ComfortView"
    	    exit 1 

            }

        else
            {
            
            Write-Host "All Dell Displays have ComfortView enabled"
            exit 0

            }
        }
    Else
        {

        Write-Host "No Dell Display is attached at the moment"
        Exit 0

        }
    }
catch
{
    $errMsg = $_.Exception.Message
    write-host $errMsg
    exit 1
}
