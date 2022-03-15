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

1.0.0   inital version


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
$env:Path = 'C:\Program Files\Dell\CommandUpdate'

# Checking missing Updates and return number of missing driver with serverity Critical or Security
cd $env:Path
$UpdateCheck = .\dcu-cli.exe /scan -updateSeverity='Security,Critical' | Select-String "Number of applicable updates for the current system configuration: "
$UpdateCount = $UpdateCheck.Line.TrimStart('Number of applicable updates for the current system configuration: ')

#prepare variable for Intune
$hash = @{ MissingUpdates = $UpdateCount }

#convert variable to JSON format
return $hash | ConvertTo-Json -Compress