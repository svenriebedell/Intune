<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.1.0
_Dev_Status_ = Test
Copyright © 2024 Dell Inc. or its subsidiaries. All Rights Reserved.

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
1.1.0   Add check timestamp of last DCU run (you can determine the maximum time since the last scan)


#>

<#
.Synopsis
   This PowerShell is for custom compliance scans and is checking this device of missing critical or security drivers .
   IMPORTANT: This scipt need a client installation of Dell Command Update UWP first. https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update
   IMPORTANT: Dell Command Update is offered as 32/64Bit and UWP App, this script used the UWP version of Dell Command Update. Otherwise you need to change the variable $env:path
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   Powershell using Dell Command Update to check missing dirvers with serverity level of critical or security. This script need to be upload in Intune Compliance / Script and need a JSON file additional for reporting this value.
   
#>

# Path where is DCU is installed need to be changed if you using the 32/64 Bit DCU
$env:Path = (Get-CimInstance -ClassName Win32_Product -Filter "Name like '%Dell%Command%Update%'").InstallLocation

# Checking missing Updates and return number of missing driver with serverity Critical or Security
Set-Location $env:Path
$UpdateCheck = .\dcu-cli.exe /scan -updateSeverity='Security,Critical' | Select-String "Number of applicable updates for the current system configuration: "
$UpdateCount = $UpdateCheck.Line.TrimStart('Number of applicable updates for the current system configuration: ')

# Checking if last scan older than 7 days
$maxAge= 7 # last dcu scan not older x days
[datetime]$regValue = (Get-ItemProperty -Path HKLM:\Software\dell\UpdateService\service -Name LastCheckTimestamp).LastCheckTimestamp
[datetime]$regDate = $regValue.AddDays($maxAge)


$currentDate = Get-Date

if ($regDate -ge $currentDate)
    {

        Write-Host "DCU scan is not older than 7 days"
        $DCUCompliance = $true

    }
else 
    {
        
        Write-Host "DCU scan is out of policy and dcu need run on this machine again"
        $DCUCompliance = $false

    }


#prepare variable for Intune
$hash = @{ MissingUpdates = $UpdateCount; LastScan = $DCUCompliance }

#convert variable to JSON format
return $hash | ConvertTo-Json -Compress