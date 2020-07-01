## Table of contents
* [SYNOPSIS](#SYNOPSIS)
* [DESCRIPTION](#DESCRIPTION)
* [EXAMPLE_Install_Terraform](#EXAMPLE Install Terraform)
* [NOTES](#NOTES)
* [EXAMPLE_List_All](#EXAMPLE List All)

## SYNOPSIS
	Download and install latest version of Terraform.exe & add it to the Windows path.

## DESCRIPTION
	Searches for the latest zip file of Terraform from the the terriform.io website and downloads it to the Program Files\Terraform. It
 	then adds 'Program Files\Terraform' to the system path if it's not already there. It will replace the existing zip and Terraform.exe file if it exists.
    
    Default: 		windows_amd64
## EXAMPLE_Install_Terraform
	# Install Terraform
	. .\install_terraform.ps1
	# Example 1: Install 64-bit version i.e. default
	GetTerraform

	# Example 2: Install 32-bit version i.e. windows_386
	GetTerraform -Version windows_386
 
 ## NOTES:
	This script only works on Windows, but if you need it to run on other operating systems, feel free to do a pull-request and add your changes.
    
    
## EXAMPLE_List_All
	# List all OS and both 32-bit/64-bit versions
	# List all OS versions. 
	.\install_terraform.ps1
	.\ListTerraformInstalls
	# List Specific OS versions. 
	.\install_terraform.ps1
	# List all linux versions...
	.\ListTerraformInstalls -Version 'linux.*'
	# List all Windows versions...
	.\ListTerraformInstalls -Version 'windows.*'
	# List only windows 386 version...
	.\ListTerraformInstalls -Version 'windows_386'
	# List only windows 64-bit version...
	.\ListTerraformInstalls -Version 'windows_amd64'
