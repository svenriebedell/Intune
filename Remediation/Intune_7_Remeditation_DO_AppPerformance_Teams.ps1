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


#>

<#
.Synopsis
   This PowerShell is setting Dell Optimizer to learn process Teams.exe by CLI command.
   IMPORTANT: Dell Optimizer is need to install first. https://www.dell.com/support/home/en-us/product-support/product/dell-optimizer/docs
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   PowerShell to import as Remediation Script for Microsoft Endpoint Manager. This Script need to be imported in Reports/Endpoint Analytics/Proactive remediation. This File is for Remediation only and need a seperate script for Detection additional. 
#>

# Variable
$env:Path = 'C:\Program Files\Dell\DellOptimizer'

# Control check by WMI
$CheckAppPerformence = @(.\do-cli.exe /get -name=AppPerformance.State | Select-String "Value") -split(": ")

#Check if AppPerformance is enabled on the device
CD $env:Path

If ($CheckAppPerformence[1] -match "True")
    {

        .\do-cli.exe /appperformance -startlearning -profilename="Microsoft Teams" -processname=Teams.exe -priority=1
    
    }
Else
    {

        .\do-cli.exe /configure -name=AppPerformance.State -value=True
        .\do-cli.exe /appperformance -startlearning -profilename="Microsoft Teams" -processname=Teams.exe -priority=1

    }

#Check success of configuration

$DOLearningApps = @(.\do-cli.exe /AppPerformance -listLearningApps | Select-String "ProcessName:") -split(": ")
   
    if ($DOLearningApps -match "Teams.exe")
        {
        write-host "Success"
    	exit 0  
        }
    Else
        {
        Write-Host "Teams is not learned by Dell Optimizer"
        exit 1
        }