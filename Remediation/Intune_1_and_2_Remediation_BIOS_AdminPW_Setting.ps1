﻿<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.2.3
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

1.2.2   add check folder c:\temp if not there new-item for $Path
        log path is now a variable $Path
1.2.3   Switch of BIOS Setting by Dell Command | Monitor to WMI agentless

#>

<#
.Synopsis
   This PowerShell for remediation by MS Endpoint Manager. This script will set a BIOS AdminPW on a Dell machine by using WMI.
   IMPORTANT: WMI BIOS is supported only on devices which developt after 2018, older devices does not supported by this powershell
   IMPORTANT: This script does not reboot the system to apply or query system.  (Put in any reboot requirements if applicable here)
.DESCRIPTION
   Powershell using WMI for setting AdminPW on the machine. The script checking if any PW is exist and can setup new and change PW. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for detection only and new a seperate script for remediation.
   
#>


#Variable for change
$PWKey = "Dell2022"

#Variable not for change
$PWset = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject -Filter "NameId='Admin'" | select -ExpandProperty IsPasswordSet
$PWstatus = ""
$DeviceName = Get-CimInstance -ClassName win32_computersystem | select -ExpandProperty Name
$serviceTag = Get-CimInstance -ClassName win32_bios | select -ExpandProperty SerialNumber
$AdminPw = "$serviceTag$PWKey"
$Date = Get-Date
$RegKeyexist = Test-Path 'HKLM:\SOFTWARE\Dell\BIOS'
$PWKeyOld = ""
$serviceTagOld = ""
$AdminPwOld = ""
$PATH = "C:\Temp\"



#Connect to the SecurityInterface WMI class
$SecurityInterface = Get-WmiObject -Namespace root\dcim\sysman\wmisecurity -Class SecurityInterface 

#check if c:\temp exist
if (!(Test-Path $PATH)) {New-Item -Path $PATH -ItemType Directory}

#Logging device data
Write-Output $env:COMPUTERNAME | out-file "$PATH\BIOS_Profile.txt" -Append
Write-Output "ServiceTag:         $serviceTag" | out-file "$PATH\BIOS_Profile.txt" -Append
Write-Output "Profile install at: $Date" | out-file "$PATH\BIOS_Profile.txt" -Append


#Checking RegistryKey availbility

if ($RegKeyexist -eq "True")
    {
    $PWKeyOld = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Dell\BIOS\' -Name BIOS | select -ExpandProperty BIOS
    $serviceTagOld = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Dell\BIOS\' -Name ServiceTag | select -ExpandProperty ServiceTag
    $AdminPwOld = "$serviceTagOld$PWKeyOld"
    Write-Output "RegKey exist"  | out-file "$PATH\BIOS_Profile.txt" -Append

    # Encoding BIOS Password
    $Encoder = New-Object System.Text.UTF8Encoding
    $Bytes = $Encoder.GetBytes($AdminPwOld)

    }
Else
    {
    New-Item -path "hklm:\software\Dell\BIOS" -Force
    New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "BIOS" -value "" -type string -Force
    New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "ServiceTag" -value "" -type string -Force
    New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "Date" -value "" -type string -Force
    New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "Status" -value "" -type string -Force
    Write-Output "RegKey is set"  | out-file "$PATH\BIOS_Profile.txt" -Append
    }

#Checking AdminPW is not set on the machine

If ($PWset -eq $false)
    {
    $PWstatus = $SecurityInterface.SetNewPassword(0,0,0,"Admin","",$AdminPw) | select -ExpandProperty Status

#Setting of AdminPW was successful

    If ($PWstatus -eq 0)
        {
        New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "BIOS" -value $PWKey -type string -Force
        New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "ServiceTag" -value $serviceTag -type string -Force
        New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "Date" -value $Date -type string -Force
        New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "Status" -value "Ready" -type string -Force

        Write-Output "Password is set successful for first time"  | out-file "$PATH\BIOS_Profile.txt" -Append
        }

#Setting of AdminPW was unsuccessful

    else
        {
        New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "Status" -value "Error" -type string -Force
        Write-Output "Error Passwort could not set" | out-file "$PATH\BIOS_Profile.txt" -Append
        }
    }


#Checking AdminPW is exsting on the machine

else
    {
    
#Compare old and new AdminPW are equal

    If ($AdminPw -eq $AdminPwOld)
        {
        Write-Output "Password no change" | out-file "$PATH\BIOS_Profile.txt" -Append

        }

#Old and new AdminPW are different make AdminPW change

    else
        {
        $SecurityInterface.SetNewPassword(1,$Bytes.Length,$Bytes,"Admin",$AdminPwOld,$AdminPw) | select -ExpandProperty Status

#Checking if change was successful

        If($PWstatus -eq 0)
            {
            Write-Output "Password is change successful" | out-file "$PATH\BIOS_Profile.txt" -Append
            New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "Status" -value "Ready" -type string -Force
            New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "BIOS" -value $PWKey -type string -Force
            }

#Checking if change was unsuccessful. Most reason is there is a AdminPW is set by user or admin before the profile is enrolled

        else
            {
            New-Itemproperty -path "hklm:\software\Dell\BIOS" -name "Status" -value "Unknown" -type string -Force
            Write-Output "Unknown password on machine. This need to delete first" | out-file "$PATH\BIOS_Profile.txt" -Append
            }
        }
    }