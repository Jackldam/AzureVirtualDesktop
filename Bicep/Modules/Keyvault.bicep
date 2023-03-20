@description('Required, Workload name')
param WorkloadName string

@description('Required, Application name')
param ApplicationName string

@description('Optional, Location')
param Location string = resourceGroup().location

@description('Required, Environment as per DTAP principal')
@allowed([ 'd', 't', 'a', 'p' ])
param Environment string

@description('Required, Administrators securitygroup id')
param AdministratorsGroupID string

var KeyvaultName = '${WorkloadName}-${ApplicationName}-${Location}-${Environment}-kv'

resource Keyvault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: KeyvaultName
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
    enablePurgeProtection: false
    enableSoftDelete: false
    accessPolicies: [
      {
        tenantId: tenant().tenantId
        objectId: AdministratorsGroupID
        permissions: {
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          storage: [
            'all'
          ]
        }
      }
    ]
  }
}
