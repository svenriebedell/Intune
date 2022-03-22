<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.0.1
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
1.0.1   integrated function for selection values and rework String Cut by select last Word


#>

<#
.Synopsis
   This PowerShell is for custom compliance scans and is checking Microsoft event for the Dell security score provide by Trusted Device Agent
   IMPORTANT: This scipt need a client installation of Dell Trusted Device Agent. https://www.dell.com/support/home/en-us/product-support/product/trusted-device/drivers
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   Powershell using Microsoft eventlog to check the Security Score and option compliances of Dell Trusted Device Agent. This script need to be upload in Intune Compliance / Script and need a JSON file additional for reporting this value.
   
#>

 
# Function for snipping SafeBIOS values from the MS Event
function Get-SafeBIOSValue{
    
    # Parameter
    param(
        [string]$Value
        
         )

    # Collect last MS Event for Trusted Device | Security Assessment
    $SelectLastLog = Get-EventLog -LogName Dell -Source "Trusted Device | Security Assessment" -Newest 1 | select -ExpandProperty message
    
    # Prepare value for single line and value
     
    $ScoreValue = ($SelectLastLog.Split([Environment]::newline) | Select-String $Value)
    $ScoreLine = ($ScoreValue.Line).Split(' ')[-1]

    $ScoreValue = $ScoreLine

    Return $ScoreValue
     
}

#Select score values
$OutputScore = Get-SafeBIOSValue -Value 'Score'
$OutputAntivirus = Get-SafeBIOSValue -Value 'Antivirus'
$OutputAdminPW = Get-SafeBIOSValue -Value 'BIOS Admin'
$OutputBIOSVerify = Get-SafeBIOSValue -Value 'BIOS Verification'
$OutputMEVerify = Get-SafeBIOSValue -Value 'ME Verification'
$OutputDiskEncrypt = Get-SafeBIOSValue -Value 'Disk Encryption'
$OutputFirewall = Get-SafeBIOSValue -Value 'Firewall solution'
$OutputIOA = Get-SafeBIOSValue -Value 'Indicators of Attack'
$OutputTPM = Get-SafeBIOSValue -Value 'TPM enabled'



# Devices without vPro should be pass the later compliance process as well but Intune could be handle only Pass or Fail, all devices without vPro Pass this section
if ($OutputMEVerify -match 'UNAVAILABLE')
    {
    $OutputMEVerify = 'Pass'
    }
Else
    {
    #No action needed
    }

#prepare variable for Intune
$hash = @{ SecurityScore = $OutputScore; AntiVirus = $OutputAntivirus; BIOSAdminPW = $OutputAdminPW; BIOSVerfication = $OutputBIOSVerify; DiskEncryption = $OutputDiskEncrypt;Firewall = $OutputFirewall; IndicatorOfAttack = $OutputIOA; TPM = $OutputTPM; vProVerification = $OutputMEVerify} 

#convert variable to JSON format
return $hash | ConvertTo-Json -Compress