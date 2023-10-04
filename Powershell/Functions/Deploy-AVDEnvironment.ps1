function Deploy-AVDEnvironment {
    param (
        [string]$EnvironmentName,
        [psobject]$PoolConfig,
        [string]$AdministratorsGroupID
    )

    Write-Host "Creating $EnvironmentName environment"

    $ResourceParams = @{
        Workload    = "AVD"
        Application = $PoolConfig.PoolName
        Location    = $PoolConfig.Location
        Environment = $EnvironmentName
    }

    $DeploymentParams = @{
        ResourceGroupName     = New-ResourceName @ResourceParams -ResourceType ResourceGroup
        keyVaultName          = New-ResourceName @ResourceParams -ResourceType Keyvault
        LocationFromTemplate  = $ResourceParams.Location
        AdministratorsGroupID = $AdministratorsGroupID
    }

    New-AzDeployment -Name $DeploymentParams.ResourceGroupName `
        -Location $ResourceParams.Location `
        @DeploymentParams `
        -TemplateFile ".\Bicep\AVDSharedResources.bicep"

    return New-KEK -VaultName $DeploymentParams.keyVaultName
}