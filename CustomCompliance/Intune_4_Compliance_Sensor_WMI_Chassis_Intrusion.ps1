<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.0.1
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
      1.0.0    inital version
      1.0.1    Add install check for Dell Command | Monitor
               Correct Failure if no value found by AttributeName Chassis Intrusion Status it will be changed to default 3
               Change get $CheckChassisSetting form native WMI to DCM


#>

<#
.Synopsis
   This PowerShell is for custom compliance scans and is checking this device of BIOS setting Intrusion detection was enabled and Intrusion Status.
   IMPORTANT: This scipt need a client installation of Dell Command Monitor https://www.dell.com/support/kbdoc/en-us/000177080/dell-command-monitor
   IMPORTANT: WMI BIOS is supported only on devices which developt after 2018, older devices does not supported by this powershell
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   Powershell using WMI to check the BIOS value of chasintrusion and ChassisIntrusionStatus. This script need to be upload in Intune Compliance / Script and need a JSON file additional for reporting this value.
   
#>

###########################################
####        Function section           ####
###########################################

# Function check Dell Command | Monitor is installed
function get-InstallStatus
    {

        $CheckInstall = Get-CimInstance -ClassName Win32_Product | Where-Object Name -Like "Dell Command | Monitor" | Select-Object -ExpandProperty Name
    
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
        <#
        Chassis Intrusion
        Disabled = no logging
        Enabled = logging with post boot alert
        SilentEnable =logging without post boot alert

        Chassis Intrusion Status

        1 = Tripped
        2 = Door open
        3 = Door closed
        4 = Trip reset

        #>

If (get-InstallStatus -eq $true)
    {

        # check chassis intrusion with WMI
        $CheckChassisSetting = Get-CimInstance -Namespace root/dcim/sysman -ClassName DCIM_BIOSEnumeration -Filter "AttributeName like 'Chassis Intrusion'" | Select-Object -ExpandProperty CurrentValue
        $CheckIntrusion = Get-CimInstance -Namespace root/dcim/sysman -ClassName DCIM_BIOSEnumeration -Filter "AttributeName like 'Chassis Intrusion Status'" | Select-Object -ExpandProperty CurrentValue

        # if varible $CheckIntrusion is empty it indicates failure with DCM Value will be set to default 3
        If($Null -eq $CheckIntrusion)
            {

                $CheckIntrusion = 3

            }

            $CheckChassisSetting = Switch ($CheckChassisSetting)
                {
                    1 {"Disabled"}
                    Default {"SilentEnable"}
                }



        #prepare variable for Intune
        $hash = @{ IntrusionSetting = $CheckChassisSetting; IntrusionStatus = $CheckIntrusion }

        #convert variable to JSON format
        return $hash | ConvertTo-Json -Compress
   
    }
else 
    {
    
        Write-Host "No Dell Command | Monitor is not installed"
        Exit 1

    }