<#
	.SYNOPSIS
		Installs the 64-bit version of Terraform.exe to "Program Files\Terraform".
	.DESCRIPTION
		Terraform is a necessary program for much of the azure infrastructure. This installs the file and makes it avalible for all users.
	.PARAMETER 
		Paramaters: 	None.
	.INPUTS
		Inputs: 		None.
	.OUTPUTS
		StdOut: 		Location.
		StdError: 		Any failures.
	.EXAMPLE
	PS> .\InstllTerraform.ps1
	.LINK
		https://github.com/GaryLBaird/Install-Terraform
#>

Function ACL-ApplyFullControl([string]$path){
	<#
	.SYNOPSIS
		You need full control to copy the Terraform.exe "Program Files\Terraform".
	.DESCRIPTION
		Only works if you are an administrator.
	#>
	# Take Ownership on Directory Give to Administrators
	$acl = Get-Acl $path
	$Group = New-Object System.Security.Principal.NTAccount("Builtin", "Administrators")
	$acl.SetOwner($Group)
	Set-Acl -Path $path -AclObject $acl
}

function Add-EnvPath {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )

    if ($Container -ne 'Session') {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
        if ($persistedPaths -notcontains $Path) {
            $persistedPaths = $persistedPaths + $Path | where { $_ }
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths -join ';', $containerType)
        }
    }

    $envPaths = $env:Path -split ';'
    if ($envPaths -notcontains $Path) {
        $envPaths = $envPaths + $Path | where { $_ }
        $env:Path = $envPaths -join ';'
    }
}

Function PathCheck($path) {
	$global:foldPath = $null
	foreach($foldername in $path.split("\")) {
		$global:foldPath += ($foldername+"\")
		if (!(Test-Path $global:foldPath)){
			New-Item -ItemType Directory -Path $global:foldPath
			# Write-Host "$global:foldPath Folder Created Successfully"
		}
	}
	ACL-ApplyFullControl $path
	return $path
}

Function GetLatest([string]$Version='windows_amd64'){
	$Count=1
	$ZipFile=@()
	$WebResponseObj = Invoke-WebRequest -Uri "https://www.Terraform.io/downloads.html"
	$WebResponseObj.Links | Foreach {
		if ($_.href -match "((\/|\\|\/\/|https?:\\\\|https?:\/\/)[a-z0-9\s_@\-^!#$%&+={}.\/\\\[\]]+)+$($Version)\.zip$"){ 
			$ZipFile += $_.href
		}
	}
	return $ZipFile
}

Function ListTerraformInstalls([string]$Version=''){
	<#
	.SYNOPSIS
		List all latest possible Terraform installs.
	.DESCRIPTION
		You might need to use a non-default version of Terraform. Using the list below you can call the 
		GetTerraform function and specify a specific version. i.e. GetTerraform -Version "windows_amd64"
	.PARAMETER Version
		Paramaters: 	None, will list all all zip files.
	.OUTPUTS
		StdOut: 		List of zip files.
	.EXAMPLE
		PS> .\ListTerraformInstalls
		Result:
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_darwin_amd64.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_freebsd_386.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_freebsd_amd64.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_freebsd_arm.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_386.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_arm.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_openbsd_386.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_openbsd_amd64.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_solaris_amd64.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_windows_386.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_windows_amd64.zip
	.EXAMPLE ListTerraformInstalls -Version "Version.*"
		PS> ListTerraformInstalls -Version "windows.*"
		Result:
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_windows_386.zip
			https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_windows_amd64.zip
	.LINK
	http://signanthealth.com/
#>
	$Count=1
	$ZipFile=@()
	$WebResponseObj = Invoke-WebRequest -Uri "https://www.terraform.io/downloads.html"
	$WebResponseObj.Links | Foreach {
		if ($_.href -match "((\/|\\|\/\/|https?:\\\\|https?:\/\/)[a-z0-9\s_@\-^!#$%&+={}.\/\\\[\]]+)+$($Version)\.zip$"){ 
			$ZipFile += $_.href
		}
	}
	return $ZipFile
}

Function GetTerraform([string]$Version='windows_amd64'){
	<#
	.SYNOPSIS
		Download and install Terraform.exe.
	.DESCRIPTION
		Gets the latest version of Terraform from the teriform.io site and downloads it to the Program Files\Terraform 
		and then adds it to the path. It will replace the existing one.
	.EXAMPLE Install 64-bit version of Terraform
		Default: 		windows_amd64
		PS> GetTerraform
		or
		PS> GetTerraform -Version 'windows_amd64'
	.EXAMPLE Install windows_386
		Default: 		windows_amd64
		Install 32-bit: windows_386
		PS> GetTerraform -Version "windows_386"
	#>
	$Source=(GetLatest $Version);
	$Destination=(Join-Path -Path $Env:ProgramFiles -Childpath "Terraform");
	PathCheck $Destination;
	$FileOut = $(split-path -path "$Source" -leaf);
	Invoke-WebRequest -Uri $Source -OutFile (Join-Path -Path $Destination -Childpath $FileOut);
	# Powershell 5 only
	Expand-Archive (Join-Path -Path $Destination -Childpath $FileOut) -DestinationPath $Destination -Force
	Add-EnvPath -Path $Destination -Container 'Machine'
}

