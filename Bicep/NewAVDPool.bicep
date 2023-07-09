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

module ResourceGroup './Modules/ResourceGroup.bicep' = {
  scope: subscription()
  name: 'ModuleResourceGroup'
  params: {
    ApplicationName: ApplicationName
    Environment: Environment
    Location: Location
    WorkloadName: WorkloadName
  }
}

module Keyvault './Modules/Keyvault.bicep' = {
  scope: resourceGroup(ResourceGroup.name)
  name: 'ModuleKeyvault'
  params: {
    AdministratorsGroupID: AdministratorsGroupID
    ApplicationName: ApplicationName
    Environment: Environment
    WorkloadName: WorkloadName
    Location: Location
  }
}

module AVDPool './Modules/AVDPool.bicep' = {
  scope: resourceGroup(ResourceGroup.name)
  name: 'AVDPool'
  params: {
    ApplicationName: ApplicationName
    Environment: Environment
    WorkloadName: WorkloadName
    Location: Location
  }
}

