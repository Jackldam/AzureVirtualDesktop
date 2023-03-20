<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>

[CmdletBinding()]
param (
)

#* find modules folder
#region

$RootPath = $PSScriptRoot
$Path = $RootPath

do {

    $ModulePath = Get-ChildItem -Path $Path -Filter "Modules" -Directory
    $Path = Split-Path -Path $Path -Parent

}
until ($ModulePath)

$Env:PSModulePath = $Env:PSModulePath+";$($ModulePath.fullname)"

##(Get-ChildItem -Path $ModulePath.FullName -Recurse -Depth 0 -Directory).FullName | ForEach-Object {
##    
##    if (!($_ -like "*\Az")) {
##        Write-Host $_ -ForegroundColor Yellow
##        Import-Module -Name $_ -Force
##    }
##
##}

#endregion