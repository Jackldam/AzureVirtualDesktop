@description('Name of the resource group')
param ResourceGroupName string

@description('Name of the Key Vault')
param keyVaultName string

@description('Administrators security group ID')
param AdministratorsGroupID string

@description('Location for the resources')
param Location string

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: ResourceGroupName
  location: Location
}

module keyVault './Modules/Keyvault.bicep' = {
  name: '${ResourceGroupName}-keyVaultModule'
  scope: resourceGroup(rg.name)
  params: {
    Location: Location
    AdministratorsGroupID: AdministratorsGroupID
    KeyVaultName: keyVaultName
  }
}

