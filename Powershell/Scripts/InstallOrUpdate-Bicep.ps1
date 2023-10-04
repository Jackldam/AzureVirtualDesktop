<#
.SYNOPSIS
This script checks if Bicep is installed, installs it if not present, or updates it to the latest version.

.DESCRIPTION
The script checks the system for the presence of the Bicep CLI. If Bicep is not detected, 
it will download and install the Bicep CLI. If an older version of Bicep is detected, 
it will be updated to the latest version.

.PARAMETER InstallPath
Specifies the path where Bicep should be installed. Defaults to 'C:\tools'.

.EXAMPLE
.\InstallOrUpdate-Bicep.ps1

.EXAMPLE
.\InstallOrUpdate-Bicep.ps1 -InstallPath "C:\myTools"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$InstallPath = 'C:\tools'
)

# Update the PATH if not already updated
if ($env:PATH -notcontains $InstallPath) {
    $env:PATH += ";$InstallPath"
}

function Get-BicepVersion {
    try {
        return & bicep --version
    } catch {
        return $null
    }
}

# Check if bicep is installed and its version
$currentVersion = Get-BicepVersion

if ($currentVersion) {
    Write-Host "Bicep version $currentVersion is installed."
    exit
} else {
    Write-Host "Bicep is not installed."
}

# Always attempt to install the latest version
Write-Host "Installing/updating to the latest Bicep version..."

# Download and install Bicep CLI
$ProgressPreference = "SilentlyContinue"
Invoke-WebRequest -Uri "https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe" -OutFile bicep.exe -UseBasicParsing

# Ensure the installation path exists
New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null

# Move the Bicep CLI to the specified directory
Move-Item -Path .\bicep.exe -Destination $InstallPath -Force


# Confirm the installed version
$newVersion = Get-BicepVersion
Write-Host "Bicep version $newVersion has been installed to $InstallPath."
