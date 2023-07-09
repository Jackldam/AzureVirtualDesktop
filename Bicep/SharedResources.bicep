@description('Required, Workload name')
param WorkloadName string

@description('Required, Application name')
param ApplicationName string

@description('Optional, Location')
param Location string

@description('Required, Environment as per DTAP principal')
@allowed([ 'd', 't', 'a', 'p' ])
param Environment string

@description('Required, Administrators securitygroup id')
param AdministratorsGroupID string

targetScope = 'subscription'

//Creation ResourceGroup for shared resources
module ResourceGroup './Modules/ResourceGroup.bicep' = {
  scope: subscription()
  name: 'SharedResourceResourceGroup'
  params: {
    WorkloadName: 'AVD'
    ApplicationName: 'SharedResources'
    Location: Location
    Environment: 'p'
  }
}

//Creation Keyvault for shared resources
module Keyvault './Modules/Keyvault.bicep' = {
  scope: resourceGroup(ResourceGroup.name)
  name: 'SharedResourceKeyVault'
  params: {
    WorkloadName: 'AVD'
    ApplicationName: 'SharedResources'
    Location: Location
    Environment: 'p'
    AdministratorsGroupID: 'AdministratorsGroupID'
  }
}



