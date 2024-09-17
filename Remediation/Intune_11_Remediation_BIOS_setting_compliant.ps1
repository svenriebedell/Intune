<#
_author_ = Sven Riebe <sven_riebe@Dell.com>
_twitter_ = @SvenRiebe
_version_ = 1.0.0
_Dev_Status_ = Test
Copyright ©2024 Dell Inc. or its subsidiaries. All Rights Reserved.

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

      1.0.0    inital version

#>

<#
.Synopsis
   This PowerShell is changing BIOS setting to required value
   IMPORTANT: WMI BIOS is supported only on devices which developt after 2018, older devices does not supported by this powershell
   IMPORTANT: This script does not reboot the system to apply or query system.
.DESCRIPTION
   Powershell using WMI to change BIOS setting to IT required values
   
#>


#########################################################################################################
####                                    Function Section                                             ####
#########################################################################################################
function write-DellRemediationEvent
    {
        
        <#
        .Synopsis
        This function write Events to Microsoft Eventlog. Need adminrights for execution.

        .Description
        This function writes standardized information from Dell Detection and Remediation scripts to EventLog Application Logname Dell Source Remediation Scripts. This makes it possible to access the information historically later for monitoring or analysis.

        Event ID 0 - 3 for Main Script (0 - Success / 1 - Error / 2 - Information / 3 - Warning )
        Event ID 10 - 13 for feedback of functions (10 - Success / 11 - Error / 12 - Information / 13 - Warning )
        Event ID 20 - 23 for Software Installation  (20 - Success / 21 - Error / 22 - Information / 23 - Warning )

        .Parameter Logname
        Value is the Name of the Eventlog it will be later under Application and Service Logs Default Dell

        .Parameter Source
        Value is the Resource and will be visible in the Event for filter options Default is RemediationScript

        .Parameter EntryType
        Value is the type of a Event like Error, Information, FailureAudit, SuccessAudit, Warning

        .Parameter EventID
        Value is a number for this event for filter options, the values are predefined for categories like MainScript, Function and Software Installation

        .Parameter Message
        Value is a message that will be visible in Event, it could be a string or JSON or XML but only one message for each event.

        Changelog:
            1.0.0 Initial Version
            1.0.1 Delete Try and Catch for testing Logname/Ressource exit and change to allway add Logname/Ressource and if exist ignor error silten.
                  Correct issue all logs are warning

        .Example
        # Write a Microsoft Event to Application and Service Logs for LogName Dell and Source RemediationScript with ID 2 for Information with the message body "Test message"
        write-DellRemediationEvent -Logname Dell -Source RemediationScript -EntryType Information -EventID '2-InformationScript' -Message "Test message"

        #>
               
        param 
            (

                [Parameter(mandatory=$false)][ValidateSet('Dell')]$Logname='Dell',
                [Parameter(mandatory=$false)][ValidateSet('RemediationScript')]$Source='RemediationScript',
                [Parameter(mandatory=$false)][ValidateSet('Error', 'Information', 'FailureAudit', 'SuccessAudit', 'Warning')]$EntryType='Information',
                [Parameter(mandatory=$true)][ValidateSet('0-SuccessScript','1-ErrorScript','2-InformationScript','3-WarningScript','10-SuccessFunction','11-ErrorFunction','12-InformationFunction','13-WarningFunction','20-SuccessInstall','21-ErrorInstall','22-InformationInstall','23-WarningInstall')][String]$EventID,
                [Parameter(mandatory=$true)]$Message

            )

        # prepare the logname and ressource name
        New-EventLog -LogName $Logname -Source $Source -ErrorAction SilentlyContinue
                
        # modify EventID to number only
        [int]$EventID = switch ($EventID) 
                    {
                        '0-SuccessScript'             {0}
                        '1-ErrorScript'               {1}
                        '2-InformationScript'         {2}
                        '3-WarningScript'             {3}
                        '10-SuccessFunction'          {10}
                        '11-ErrorFunction'            {11}
                        '12-InformationFunction'      {12}
                        '13-WarningFunction'          {13}
                        '20-SuccessInstall'           {20}
                        '21-ErrorInstall'             {21}
                        '22-InformationInstall'       {22}
                        '23-WarningInstall'           {23}
                        Default {2}
                    }

        # Value validation if Entrytype match to EventID if not it change the Entrytype to the correct type

        if ($EventID -eq 0 -or $EventID -eq 10 -or $EventID -eq 20)
            {
                $EntryType = 'SuccessAudit'                    
            }
        if (($EventID -eq 1) -or ($EventID -eq 11) -or ($EventID -eq 21))
            {
                $EntryType = 'Error'                    
            }
        if (($EventID -eq 2) -or ($EventID -eq 12) -or ($EventID -eq 22))
            {
                $EntryType = 'Information'
            }
        if (($EventID -eq 3) -or ($EventID -eq 13) -or ($EventID -eq 23))
            {
                $EntryType = 'Warning'
            }


        # write log information
        Write-EventLog -LogName $Logname -Source $Source -EntryType $EntryType -EventID $EventID -Message $Message

    }

function set-BIOSSetting
    {
        
        <#
        .Synopsis
        This function changing the Dell Client BIOS Settings by CIM

        .Description
        This function allows you agentless to set BIOS Pasword or to change BIOS Settings

        .Parameter SettingName
        Value is the name of the BIOS setting

        .Parameter SettingValue
        This is the value is the BIOS setting value, e.g. enabled or disabled or if you set/Change the new Password

        .Parameter BIOSPW
        This is the value is the existing BIOS Password set on the device. It will only needed if a BIOS Password is set on the device.


        Changelog:
            1.0.0 Initial Version
            1.0.1 add return for setting returncode to the mainscript


        .Example
        This example will set the Chassis Intrusion detection to SilentEnable, if the Device has no BIOS Admin Password.
        
        set-BIOSSetting -SettingName ChasIntrusion -SettingValue SilentEnable

        .Example
        This example will set the Chassis Intrusion detection to SilentEnable, if the Device has BIOS Admin Password.
        
        set-BIOSSetting -SettingName ChasIntrusion -SettingValue SilentEnable -BIOSPW <Your BIOS Admin PWD>

        .Example
        This example will set a new BIOS Admin Password for the first time
        
        set-BIOSSetting -SettingName Admin -SettingValue <Your BIOS Admin PWD>

        .Example
        This example will change BIOS Admin Password
        
        set-BIOSSetting -SettingName Admin -SettingValue <Your NEW BIOS Admin PWD> -BIOSPW <Your OLD BIOS Admin PWD>

        .Example
        This example will Clear BIOS Admin Password
        
        set-BIOSSetting -SettingName Admin -SettingValue ClearPWD -BIOSPW <Your OLD BIOS Admin PWD>

        #>
               
        param 
            (

                [Parameter(mandatory=$true)] [String]$SettingName,
                [Parameter(mandatory=$true)] [String]$SettingValue,
                [Parameter(mandatory=$false)] [String]$BIOSPW

            )


        #########################################################################################################
        ####                                    Program Section                                              ####
        #########################################################################################################

        # connect BIOS Interface
        try 
            {
                # get BIOS WMI Interface
                $BIOSInterface = Get-CimInstance -Namespace root\dcim\sysman\biosattributes -Class BIOSAttributeInterface -ErrorAction Stop
                $SecurityInterface = Get-CimInstance -Namespace root\dcim\sysman\wmisecurity -Class SecurityInterface -ErrorAction Stop
                Write-Host "BIOS Interface connected" -ForegroundColor Green
            }
        catch 
            {
                Write-Host "Error : BIOS interface access denied or unreachable" -ForegroundColor Red
                Write-Host "Status : false"
                Exit 1
            }


        # Check if BIOS Setting need BIOS Admin PWD
        try
            {
                # Check BIOS AttributName AdminPW is set
                $BIOSAdminPW = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject -Filter "NameId='Admin'" | Select-Object -ExpandProperty IsPasswordSet

                if ($BIOSAdminPW -match "1")
                    {
                        Write-Host "BIOS Admin PW is set on this Device"
                        
                        If ($null -eq $BIOSPW)
                            {
                                Write-Host "Message : required parameter BIOSPW is empty"
                                Return $false, "3"
                                Exit 1
                            }
                        
                        #Get encoder for encoding password
                        $encoder = New-Object System.Text.UTF8Encoding
                                        
                        #encode the password
                        $AdminBytes = $encoder.GetBytes($BIOSPW)

                        If (($SettingName -ne "Admin") -and ($SettingName -ne "System"))
                            {
                                ######################################
                                ####  BIOS Setting with Admin PWD ####
                                ######################################
                                        
                                try 
                                    {
                                        # Argument
                                        $argumentsWithPWD = @{
                                                                AttributeName=$SettingName; 
                                                                AttributeValue=$SettingValue; 
                                                                SecType=1; 
                                                                SecHndCount=$AdminBytes.Length; 
                                                                SecHandle=$AdminBytes;
                                                            }
                                                
                                        # Set a BIOS Attribute
                                        Write-Host "Set Bios"
                                        $SetResult = Invoke-CimMethod -InputObject $BIOSInterface -MethodName SetAttribute -Arguments $argumentsWithPWD -ErrorAction Stop
                                                
                                        If ($SetResult.Status -eq 0)
                                            {
                                                Write-Host "Message : BIOS setting success"
                                                return $true
                                            }
                                        else 
                                            {
                                                switch ( $SetResult.Status )
                                                    {
                                                        0 { $result = 'Success' }
                                                        1 { $result = 'Failed' }
                                                        2 { $result = 'Invalid Parameter' }
                                                        3 { $result = 'Access Denied'  }
                                                        4 { $result = 'Not Supported' }
                                                        5 { $result = 'Memory Error'  }
                                                        6 { $result = 'Protocol Error' }
                                                        default { $result ='Unknown' }
                                                    }
                                                Write-Host "Message : BIOS setting $result"
                                                return $false, $SetResult.Status
                                            }
                                    }
                                catch 
                                    {
                                        $errMsg = $_.Exception.Message
                                        write-host $errMsg
                                        If ($SetResult.Status -eq 0)
                                            {
                                                Write-Host "Message : BIOS setting success"
                                                return $true
                                            }
                                        else 
                                            {
                                                        switch ( $SetResult.Status )
                                                            {
                                                                0 { $result = 'Success' }
                                                                1 { $result = 'Failed' }
                                                                2 { $result = 'Invalid Parameter' }
                                                                3 { $result = 'Access Denied'  }
                                                                4 { $result = 'Not Supported' }
                                                                5 { $result = 'Memory Error'  }
                                                                6 { $result = 'Protocol Error' }
                                                                default { $result ='Unknown' }
                                                            }
                                                        Write-Host "Message : BIOS Password setting $result"
                                                        return $false, $SetResult.Status
                                                        exit 1
                                            }
                                    }
                            }
                        else 
                            {
                                ################################################
                                ####  BIOS Change/Delete Admin or Sytem PWD ####
                                ################################################
                                try 
                                    {
                                        If($SettingValue -eq "ClearPWD")
                                            {
                                                Write-Host "Admin PWD clear"
                                                # Argument
                                                $argumentsWithPWD = @{
                                                                        NameId=$SettingName;
                                                                        NewPassword="";
                                                                        OldPassword=$BIOSPW;
                                                                        SecType=1;
                                                                        SecHndCount=$AdminBytes.Length;
                                                                        SecHandle=$AdminBytes;
                                                                    }
                                            }
                                        else 
                                            {
                                                Write-Host "Admin PWD change"
                                                # Argument
                                                $argumentsWithPWD = @{
                                                                        NameId=$SettingName;
                                                                        NewPassword=$SettingValue;
                                                                        OldPassword=$BIOSPW;
                                                                        SecType=1;
                                                                        SecHndCount=$AdminBytes.Length;
                                                                        SecHandle=$AdminBytes;
                                                                    }
                                            }
 
                    
                                        # Set a BIOS Attribute
                                        $SetResult = Invoke-CimMethod -InputObject $SecurityInterface -MethodName SetnewPassword -Arguments $argumentsWithPWD #-ErrorAction Stop
                                        
                                        If ($SetResult.Status -eq 0)
                                            {
                                                Write-Host "Message : BIOS Password setting success"
                                                return $true
                                            }
                                        else 
                                            {
                                                switch ( $SetResult.Status )
                                                    {
                                                        0 { $result = 'Success' }
                                                        1 { $result = 'Failed' }
                                                        2 { $result = 'Invalid Parameter' }
                                                        3 { $result = 'Access Denied'  }
                                                        4 { $result = 'Not Supported' }
                                                        5 { $result = 'Memory Error'  }
                                                        6 { $result = 'Protocol Error' }
                                                        default { $result ='Unknown' }
                                                    }
                                                Write-Host "Message : BIOS Password setting $result"
                                                return $false, $SetResult.Status
                                            }
                                    }
                                catch 
                                    {
                                        $errMsg = $_.Exception.Message
                                        write-host $errMsg
                                        If ($SetResult.Status -eq 0)
                                            {
                                                Write-Host "Message : BIOS Password setting success"
                                                return $true
                                            }
                                        else 
                                            {
                                                switch ( $SetResult.Status )
                                                    {
                                                        0 { $result = 'Success' }
                                                        1 { $result = 'Failed' }
                                                        2 { $result = 'Invalid Parameter' }
                                                        3 { $result = 'Access Denied'  }
                                                        4 { $result = 'Not Supported' }
                                                        5 { $result = 'Memory Error'  }
                                                        6 { $result = 'Protocol Error' }
                                                        default { $result ='Unknown' }
                                                    }
                                                Write-Host "Message : BIOS Password setting $result"
                                                return $false, $SetResult.Status
                                                exit 1
                                            }
                                    }                                      
                            }
                    }
                Else
                    {
                        Write-Host "No BIOS Admin PW is set on this Device"

                        If (($SettingName -ne "Admin") -and ($SettingName -ne "System"))
                            {
                                #########################################
                                ####  BIOS Setting without Admin PWD ####
                                #########################################
                                try 
                                    {
                                        # Argument
                                        $argumentsNoPWD = @{ 
                                                                AttributeName=$SettingName; 
                                                                AttributeValue=$SettingValue;
                                                                SecType=0;
                                                                SecHndCount=0;
                                                                SecHandle=@()
                                                            }  
                                        
                                        Write-Host "Set Bios Settings"
                                        # Set a BIOS Attribute ChasIntrusion to EnabledSilent (BIOS password is not set)
                                        $SetResult = Invoke-CimMethod -InputObject $BIOSInterface -MethodName SetAttribute -Arguments $argumentsNoPWD -ErrorAction Stop
        
                                        If ($SetResult.Status -eq 0)
                                            {
                                                Write-Host "Message : BIOS setting success"
                                                return $true
                                            }
                                        else 
                                            {
                                                switch ( $SetResult.Status )
                                                    {
                                                        0 { $result = 'Success' }
                                                        1 { $result = 'Failed' }
                                                        2 { $result = 'Invalid Parameter' }
                                                        3 { $result = 'Access Denied'  }
                                                        4 { $result = 'Not Supported' }
                                                        5 { $result = 'Memory Error'  }
                                                        6 { $result = 'Protocol Error' }
                                                        default { $result ='Unknown' }
                                                    }
                                                Write-Host "Message : BIOS setting $result"
                                                return $false, $SetResult.Status
                                            }
                                    }
                                catch 
                                    {
                                        $errMsg = $_.Exception.Message
                                        write-host $errMsg
                                        Write-Host "Message : BIOS setting failed"
                                        return $false, $SetResult.Status
                                        exit 1
                                    }


                            }
                        else 
                            {
                                ######################################
                                ####  BIOS Set Admin or Sytem PWD ####
                                ######################################
                                try 
                                    {
                                        
                                        # Argument
                                        $argumentsNoPWD = @{
                                                                NameId=$SettingName;
                                                                NewPassword=$SettingValue;
                                                                OldPassword="";
                                                                SecType=0;
                                                                SecHndCount=0;
                                                                SecHandle=@();
                                                            }
                                        
                                        Write-Host "Set Password"
                                        
                                        # Set a BIOS Passwords
                                        $SetResult = Invoke-CimMethod -InputObject $SecurityInterface -MethodName SetnewPassword -Arguments $argumentsNoPWD -ErrorAction Stop
        
                                        If ($SetResult.Status -eq 0)
                                            {
                                                Write-Host "Message : BIOS Password setting success"
                                                return $true
                                            }
                                        else 
                                            {
                                                switch ( $SetResult.Status )
                                                    {
                                                        0 { $result = 'Success' }
                                                        1 { $result = 'Failed' }
                                                        2 { $result = 'Invalid Parameter' }
                                                        3 { $result = 'Access Denied'  }
                                                        4 { $result = 'Not Supported' }
                                                        5 { $result = 'Memory Error'  }
                                                        6 { $result = 'Protocol Error' }
                                                        default { $result ='Unknown' }
                                                    }
                                                Write-Host "Message : BIOS setting $result"
                                                return $false, $SetResult.Status
                                            }
                                    }
                                catch 
                                    {
                                        $errMsg = $_.Exception.Message
                                        write-host $errMsg
                                        Write-Host "Message : BIOS setting failed"
                                        return $false, $SetResult.Status
                                        exit 1
                                    }
                            }
                    }
            }
        catch
            {
                $errMsg = $_.Exception.Message
                write-host $errMsg
                If ($SetResult.Status -eq 0)
                    {
                        Write-Host "Message : BIOS setting success"
                        return $true
                    }
                else 
                    {
                        switch ( $SetResult.Status )
                            {
                                0 { $result = 'Success' }
                                1 { $result = 'Failed' }
                                2 { $result = 'Invalid Parameter' }
                                3 { $result = 'Access Denied'  }
                                4 { $result = 'Not Supported' }
                                5 { $result = 'Memory Error'  }
                                6 { $result = 'Protocol Error' }
                                default { $result ='Unknown' }
                            }
                        Write-Host "Message : BIOS Password setting $result"
                        return $false, $SetResult.Status
                    }
                write-host "Status : False"
                exit 1
            }
    }

#########################################################################################################
####                                    Varible Section                                              ####
#########################################################################################################

$BIOSCompliant = @(
                    [PSCustomObject]@{BIOSSettingName = "AutoOSRecoveryThreshold"; BIOSSettingValue = "2"; WMIClass = "EnumerationAttribute"}
                    [PSCustomObject]@{BIOSSettingName = "SupportAssistOSRecovery"; BIOSSettingValue = "Enabled"; WMIClass = "EnumerationAttribute"}
                    [PSCustomObject]@{BIOSSettingName = "BIOSConnect"; BIOSSettingValue = "Enabled"; WMIClass = "EnumerationAttribute"}    
                    )

$BIOSPWD = "Add here your BIOS Admin Password if you have"


#########################################################################################################
####                                    Program Section                                              ####
#########################################################################################################

# get BIOS setting from device

try 
    {
        [array]$BIOSCompliantStatus = @()
        
        foreach ($Setting in $BIOSCompliant)
            {
                # Temp Array
                $TempBIOSStatus = New-Object -TypeName psobject
                
                $TempBIOSStatus = Get-CimInstance -Namespace root/dcim/sysman/biosattributes -ClassName $Setting.WMIClass -ErrorAction Stop| Where-Object {$_.AttributeName -eq $Setting.BIOSSettingName} -ErrorAction Stop| Select-Object AttributeName, CurrentValue
            
                [array]$BIOSCompliantStatus += $TempBIOSStatus
            }
    }
catch 
    {
        $errMsg = $_.Exception.Message
        Write-Host "Get BIOS settings failed"

        # write the result to Microsoft Eventlog
        $ScriptMessage = @{ 
                            NameScript = "IntuneDetectionBIOSSettings";
                            ScriptExecution = $errMsg
                          }
        $ScriptMessageJSON = $ScriptMessage | ConvertTo-Json
        write-DellRemediationEvent -Logname Dell -Source RemediationScript -EventId '3-WarningScript' -Message $ScriptMessageJSON
        Exit 1
    }

foreach ($Status in $BIOSCompliantStatus)
    {
        
        ForEach ($Compliant in $BIOSCompliant)
            {
                If ($Compliant.BIOSSettingName -eq $Status.AttributeName)
                    {                 

                        If($Compliant.BIOSSettingValue -eq $Status.CurrentValue)
                            {
                                Write-Host $Status.AttributeName "setting not changed"

                            }
                        else 
                            {
                                $result = set-BIOSSetting -SettingName $Status.AttributeName -SettingValue ($BIOSCompliant | Where-Object {$_.BIOSSettingName -eq $Status.AttributeName}).BIOSSettingValue -BIOSPW $BIOSPWD
                                
                                If ($result -eq $true)
                                    {
                                        Write-Host $Status.AttributeName "setting is changed"
                                        # write the result to Microsoft Eventlog
                                        $ScriptMessage = @{ 
                                                            NameScript = "IntuneRemediationBIOSSettings";
                                                            Settings = $Status.AttributeName
                                                            BIOSSettingsSuccess = $true
                                                        }
                                        $ScriptMessageJSON = $ScriptMessage | ConvertTo-Json
                                        write-DellRemediationEvent -Logname Dell -Source RemediationScript -EventId '2-InformationScript' -Message $ScriptMessageJSON
                                    }
                                else 
                                    {
                                        Write-Host "BIOS setting failed wrong parameter or wrong BIOS Password" -ForegroundColor Red

                                        # write the result to Microsoft Eventlog
                                        $ScriptMessage = @{ 
                                                            NameScript = "IntuneRemediationBIOSSettings";
                                                            RemediationSuccess = $false
                                                                }
                                        $ScriptMessageJSON = $ScriptMessage | ConvertTo-Json
                                        write-DellRemediationEvent -Logname Dell -Source RemediationScript -EventId '3-WarningScript' -Message $ScriptMessageJSON
                                        Exit 1
                                    }
                            }
                    }    	
            }
    }


Write-Host "Remediation script successful"

# write the result to Microsoft Eventlog
$ScriptMessage = @{ 
                    NameScript = "IntuneRemediationBIOSSettings";
                    RemediationSuccess = $true
                }
$ScriptMessageJSON = $ScriptMessage | ConvertTo-Json
write-DellRemediationEvent -Logname Dell -Source RemediationScript -EventId '2-InformationScript' -Message $ScriptMessageJSON
Exit 0

#########################################################################################################
####                                    END                                                          ####
#########################################################################################################