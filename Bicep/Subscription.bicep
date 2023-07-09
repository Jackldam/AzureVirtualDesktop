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

targetScope = 'tenant'

resource Subscription 'Microsoft.Subscription/aliases@2021-10-01' = {
  name: 'AzureVirtualDesktop'
}

// Creation of shared resourcegroup
module SharedResourceGroup './SharedResources.bicep' = {
  scope: subscription(Subscription.id)
  name: 'SharedResourceGroup'
  params: {
    AdministratorsGroupID: AdministratorsGroupID
    ApplicationName: ApplicationName
    Environment: Environment
    Location: Location
    WorkloadName: WorkloadName
  }
}


// Creation of new AVDPool
module NewAVDPool './NewAVDPool.bicep' = {
  scope: subscription(Subscription.id)
  name: 'Build New AVD Pool'
  params: {
    AdministratorsGroupID: AdministratorsGroupID
    ApplicationName: ApplicationName
    Environment: Environment
    Location: Location
    WorkloadName: WorkloadName
  }
}

