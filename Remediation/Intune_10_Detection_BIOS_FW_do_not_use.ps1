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
   This PowerShell is checking online BIOS Catalog and Compare with the real version of a Client. If the Client Version low it will show Update needed.
   IMPORTANT: WMI BIOS is supported only on devices which developt after 2018, older devices does not supported by this powershell
   IMPORTANT: This script does not reboot the system to apply or query system.

.DESCRIPTION
   PowerShell to import as Dection Script for Microsoft Endpoint Manager. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for detection only and need a seperate script for remediation additional.
#>

try{
    
    [XML]$BIOS_Catalog = (New-Object System.Net.WebClient).DownloadString("https://dl.dell.com/catalog/BiosPc.xml")


    
    #Check if AdminPW is set on the machine
    $BIOSAdminPW = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject -Filter "NameId='Admin'" | Select-Object -ExpandProperty IsPasswordSet
         
    if ($ddd -match "1")
        {
        
        #check if BIOS password older that 180 days
        $DateExpire = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Dell\BIOS\' -Name Update | Select-Object -ExpandProperty Update

        if ((Get-Date -Format yyyyMMdd) -le (Get-Date $DateExpire -Format yyyyMMdd))
            {

            write-host "Success"
    	    exit 0 

            }

        else
            {
            
            Write-Host "AdminPW is older than 180 days"
            exit 1

            }
        }      
        
               
    Else
        {
        
        Write-Host "No AdminPW is exiting, no PW Change is needing"
        exit 0
        
        }
    }
catch
{
    $errMsg = $_.Exception.Message
    write-host $errMsg
    exit 1
}
