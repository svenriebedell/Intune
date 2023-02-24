<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.1.0
_Dev_Status_ = Test
Copyright © 2023 Dell Inc. or its subsidiaries. All Rights Reserved.

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

<#Change Log

1.0.0   inital version
1.0.1   integrated function for selection values and rework String Cut by select last Word
1.1.0   Some kinds of detections shows UNAVAILABLE or WARNING this will be translate to PASS by function set-value. 
        Switching Single Values to Array
        Checking if Trusted Device is installed first


#>

<#
.Synopsis
   This PowerShell is for custom compliance scans and is checking Microsoft event for the Dell security score provide by Trusted Device Agent
   IMPORTANT: This scipt need a client installation of Dell Trusted Device Agent. https://www.dell.com/support/home/en-us/product-support/product/trusted-device/drivers
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   Powershell using Microsoft eventlog to check the Security Score and option compliances of Dell Trusted Device Agent. This script need to be upload in Intune Compliance / Script and need a JSON file additional for reporting this value.
   
#>

###########################################
####        Function section           ####
###########################################

# Function for snipping SafeBIOS values from the MS Event
function Get-SafeBIOSValue
    {
    
        # Parameter
        param(
            [string]$Value
            
            )

        # Collect last MS Event for Trusted Device | Security Assessment
        $SelectLastLog = Get-EventLog -LogName Dell -Source "Trusted Device | Security Assessment" -Newest 1 | Select-Object -ExpandProperty message
        
        # Prepare value for single line and value
        
        $ScoreValue = ($SelectLastLog.Split([Environment]::newline) | Select-String $Value)
        $ScoreLine = ($ScoreValue.Line).Split(' ')[-1]

        $ScoreValue = $ScoreLine

        Return $ScoreValue
     
    }

# Function for changing Value to FAIL or PASS
function set-Value 
    {
        param
            (
                [Parameter(mandatory=$true)][string]$valueSafeBIOS
            )

        switch ($valueSafeBIOS) 
            {
                FAIL {"FAIL"}
                Default {"PASS"}
            }
    
    }

# Function check Dell Trusted Device is installed
function get-InstallStatus
    {

        $CheckInstall = Get-CimInstance -ClassName Win32_Product | Where-Object Name -Like "Dell Trusted Device Agent" | Select-Object -ExpandProperty Name
    
        If ($null -ne $CheckInstall)
            {

                Return $true

            }
        else 
            {
            
                Return $false
            
            }
    }


###########################################
####        Program section            ####
###########################################

If (get-InstallStatus -eq $true)
    {

        #Select score values
        $SafeBIOS = @(
            [PSCustomObject]@{Name = "Score"; Value = Get-SafeBIOSValue -Value 'Score'}
            [PSCustomObject]@{Name = "Antivirus"; Value = Get-SafeBIOSValue -Value 'Antivirus'}
            [PSCustomObject]@{Name = "BIOSPWD"; Value = Get-SafeBIOSValue -Value 'BIOS Admin'}
            [PSCustomObject]@{Name = "BIOSVerification"; Value = Get-SafeBIOSValue -Value 'BIOS Verification'}
            [PSCustomObject]@{Name = "MEVerification"; Value = Get-SafeBIOSValue -Value 'ME Verification'}
            [PSCustomObject]@{Name = "DiskEncryption"; Value = Get-SafeBIOSValue -Value 'Disk Encryption'}
            [PSCustomObject]@{Name = "Firewall"; Value = Get-SafeBIOSValue -Value 'Firewall solution'}
            [PSCustomObject]@{Name = "IAO"; Value = Get-SafeBIOSValue -Value 'Indicators of Attack'}
            [PSCustomObject]@{Name = "TPM"; Value = Get-SafeBIOSValue -Value 'TPM enabled'}
            )

        # Replacing informations like WARINING, UNAVAILABLE, default Value = PASS
        foreach ($SafeResult in $SafeBIOS)
            {

                if($SafeResult.Name -ne "Score")
                    {

                        $SafeResult.Value = set-Value -valueSafeBIOS $SafeResult.Value

                    }

            }

        #prepare variable for Intune
        $hash = @{ SecurityScore = ($SafeBIOS | Where-Object Name -eq "Score" | Select-Object -ExpandProperty Value) ; AntiVirus = ($SafeBIOS | Where-Object Name -eq "Antivirus" | Select-Object -ExpandProperty Value); BIOSAdminPW = ($SafeBIOS | Where-Object Name -eq "BIOSPWD" | Select-Object -ExpandProperty Value); BIOSVerfication = ($SafeBIOS | Where-Object Name -eq "BIOSVerification" | Select-Object -ExpandProperty Value); DiskEncryption = ($SafeBIOS | Where-Object Name -eq "DiskEncryption" | Select-Object -ExpandProperty Value); Firewall = ($SafeBIOS | Where-Object Name -eq "Firewall" | Select-Object -ExpandProperty Value); IndicatorOfAttack = ($SafeBIOS | Where-Object Name -eq "IAO" | Select-Object -ExpandProperty Value); TPM = ($SafeBIOS | Where-Object Name -eq "TPM" | Select-Object -ExpandProperty Value); vProVerification = ($SafeBIOS | Where-Object Name -eq "MEVerification" | Select-Object -ExpandProperty Value)} 

        #convert variable to JSON format
        return $hash | ConvertTo-Json -Compress

    }
else 
    {
    
        Write-Host "No Dell Trusted Device is installed"
        Exit 1

    }