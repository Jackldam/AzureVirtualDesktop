@description('Required, Workload name')
param KeyVaultName string

@description('Location of the KeyVault. Defaults to the resource group location.')
param Location string

@description('Required, Administrators security group id')
param AdministratorsGroupID string

resource Keyvault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: KeyVaultName
  location: Location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    createMode: 'default'
    enabledForTemplateDeployment: true
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    accessPolicies: [
      {
        tenantId: tenant().tenantId
        objectId: AdministratorsGroupID
        permissions: {
          certificates: [
            'all'
            'purge'
          ]
          keys: [
            'all'
          ]
          secrets: [
            'all'
            'purge'
          ]
          storage: [
            'all'
            'purge'
          ]
        }
      }
    ]
  }
}

output KeyvaultId string = Keyvault.id
