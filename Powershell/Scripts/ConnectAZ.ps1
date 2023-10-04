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

#* Load functions
#region
. ".\Powershell\Functions\New-ResourceName.ps1"
. ".\Powershell\Functions\Read-ConfigFile.ps1"
. ".\Powershell\Functions\Deploy-AVDEnvironment.ps1"
. ".\Powershell\Functions\New-KEK.ps1"
. ".\Powershell\Scripts\InstallOrUpdate-Bicep.ps1"
. ".\Powershell\Scripts\LoadModules.ps1"
#endregion


try {
    $ErrorActionPreference = "Stop"

    $Config = Get-ChildItem -Path . -Recurse -Filter "CoreConfig.config" | Read-ConfigFile


    #* Connect AzAccount
    #region

    #Disable AZ Context auto save for this process
    Disable-AzContextAutosave -Scope CurrentUser

    $AzAccount = @{
        Tenant       = $Config.Tenant
        Subscription = $Config.Subscription
    }

    # Get the current context
    $context = Get-AzContext

    # Check if context exists
    if ($context) {
        Write-Host "Connected to Azure as $($context.Account.Id) in subscription $($context.Subscription.Id)."
    }
    else {
        Write-Host "Not connected to Azure."
        Connect-AzAccount @AzAccount -SkipContextPopulation
    }

    #endregion

    #* AVD Core Deployment
    #region

    $ResourceParams = @{
        Workload    = "AVD"
        Application = "Core"
        Location    = "westeurope"
        Environment = "Production"
    }

    $DeploymentParams = @{
        ResourceGroupName     = New-ResourceName @ResourceParams -ResourceType ResourceGroup
        keyVaultName          = New-ResourceName @ResourceParams -ResourceType Keyvault
        LocationFromTemplate  = $ResourceParams.Location
        AdministratorsGroupID = $Config.AVDAdministratorsGroupID
    }

    New-AzDeployment -Name $DeploymentParams.ResourceGroupName `
        -Location $ResourceParams.Location `
        @DeploymentParams `
        -TemplateFile ".\Bicep\AVDSharedResources.bicep"

    #*KEK creation and getting ID
    #region

    $AzKeyVaultKeyParams = @{
        VaultName = $DeploymentParams.keyVaultName
        Name      = "KEK" 
    }

    $AzKeyVaultKeyId = $(Get-AzKeyVaultKey @AzKeyVaultKeyParams).Id
    if (-not [bool]$AzKeyVaultKeyId) {
        $AzKeyVaultKeyId = $(Add-AzKeyVaultKey @AzKeyVaultKeyParams -KeyType RSA -Size 	4096 -Destination Software).id
    }

    #endregion

    #*DomainJoinUserName creation and getting ID
    #region

    $AzKeyVaultSecretParams = @{
        VaultName = $DeploymentParams.keyVaultName
        Name      = "DomainJoinUserName" 
    }

    $AzKeyVaultSecretDomainJoinUserNameId = $(Get-AzKeyVaultSecret @AzKeyVaultSecretParams).Id
    if (-not [bool]$AzKeyVaultSecretDomainJoinUserNameId) {
        $AzKeyVaultSecretDomainJoinUserNameId = $(Set-AzKeyVaultSecret @AzKeyVaultSecretParams -SecretValue $("DomainJoinUserName" | ConvertTo-SecureString -AsPlainText -Force)).id
    }

    #endregion

    #*DomainJoinPassword creation and getting ID
    #region

    $AzKeyVaultSecretParams = @{
        VaultName = $DeploymentParams.keyVaultName
        Name      = "DomainJoinPassword" 
    }

    $AzKeyVaultSecretDomainJoinPasswordId = $(Get-AzKeyVaultSecret @AzKeyVaultSecretParams).Id
    if (-not [bool]$AzKeyVaultSecretDomainJoinPasswordId) {
        $AzKeyVaultSecretDomainJoinPasswordId = $(Set-AzKeyVaultSecret @AzKeyVaultSecretParams -SecretValue $("DomainJoinPassword" | ConvertTo-SecureString -AsPlainText -Force)).id
    }

    #endregion



    #endregion

    #* AVD Pool Deployment
    #region
    Get-ChildItem -Path ".\Config" -Filter "*.pool" | 
    Where-Object Name -NotLike "Example*" | 
    ForEach-Object {
        $PoolConfig = $_ | Read-ConfigFile

        if ($PoolConfig) {
            foreach ($env in @("Development", "Testing", "Acceptance", "Production")) {
                if ($PoolConfig.$env) {
                    Deploy-AVDEnvironment -EnvironmentName $env -PoolConfig $PoolConfig -AdministratorsGroupID $Config.AVDAdministratorsGroupID
                }
            }
        }
        #endregion
    }
}
catch {
    throw $_
}