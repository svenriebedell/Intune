# Intune Examples for Custom Compliance and Detection/Remediation with Dell Clients

This repository includes some examples to manage Dell Clients with Microsoft Endpoint Manager. Sample scripts are written in PowerShell that illustrates the usage of these scripts with UEM management and dashboarding and analytics platforms to provide various data elements from Dell client tools or OS.

All Code is free for us, but without out support and warranty.
Please beware script with the Tag Dev_Status_ = Test are Alpha Version it could be they does not work correctly. 



Windows Management Instrumentation and PowerShell
Windows Management Instrumentation (WMI) is the infrastructure to manage the data and operations on Windows based operating systems.

PowerShell offers cross-platform task automation and configuration management framework through command-line instructions and scripting language.

Most of the Dell commercial client systems are Windows-based, WMI and PowerShell are available in the IT infrastructure. This allows the IT professionals to integrate the scripts with their existing infrastructure or develop custom scripts based on their requirements. Microsoft has done a great job enhancing the PowerShell capabilities to integrate and manage WMI infrastructure.

The Dell commercial client BIOS offers configurable entities through WMI, and the script library provides sample scripts to accomplish the tasks. This method configures the Dell business client systems that contain the common interface across multiple brands, including Latitude, OptiPlex, Precision, and XPS laptops. It enhances the hardware management features and does not change across the various versions of the Windows operating systems.

Learning more about WMI and PowerShell
For more details on WMI, see [https://docs.microsoft.com/en-us/windows/win32/wmisdk/wmi-start-page] For more details on PowerShell, see [https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7] For more details on Agentless BIOS manageability, see [https://downloads.dell.com/manuals/common/dell-agentless-client-manageability.pdf]

Microsoft Intune
Microsoft Intune is a cloud-based service that focuses on Mobile Device Management (MDM). For more details on Microsoft Intune, see [https://docs.microsoft.com/en-us/mem/intune/fundamentals/what-is-intune]

Deploying a PowerShell script from Intune
The Microsoft Intune management extension allows you to upload the PowerShell scripts in Intune. You can run these scripts on the systems which are running on Windows 10 operating systems. The management extension enhances the Mobile Device Management (MDM) capabilities. For more information about Deploying a PowerShell script from Intune, see [https://docs.microsoft.com/en-us/mem/intune/apps/intune-management-extension]

Client script library
This GitHub library offers the PowerShell scripts that illustrate the usage of the agentless BIOS manageability to perform the following 


#Remediation/Detection operations:

Configure BIOS passwords

Configure BIOS attribute(s)

Configure BIOS Password change after specific time

Checking/update missing critical drivers

Checking/Configure Display settings

Checking Dell SafeBIOS status


#Custom Compliance:
Checking Support Contract

Checking Dell SafeBIOS

Checking missing critical drivers

Checking chassis intrusion



#Prerequisites
Dell commercial client systems that are released to market after calendar year 2018
Windows operating system
PowerShell 5.0 or later
Support
This code is provided to help the open-source community and currently not supported by Dell.

Install Dell Display Manager delldisplaymanager.com

Install Dell Trusted Device Agent https://www.dell.com/support/home/en-us/product-support/product/trusted-device/drivers

Install Dell Command Update Universal Windows Plattform (Win10/11 Version) https://www.dell.com/support/kbdoc/en-us/000177325/dell-command-update

Provide feedback or report an issue
You can provide further feedback or report an issue by using the following link [https://github.com/svenriebedell]
