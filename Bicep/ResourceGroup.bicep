@description('Required, Workload name')
param WorkloadName string

@description('Required, Application name')
param ApplicationName string

@description('Required, Location')
param Location string

@description('Required, Environment as per DTAP principal')
@allowed(['d','t','a','p'])
param Environment string

var ResourceGroupName = '${WorkloadName}-${ApplicationName}-${Location}-${Environment}-rg'

targetScope = 'subscription'

resource ResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: ResourceGroupName
  location: Location
}

// module LogAnalyticsWorkSpace 'LogAnalyticsWorkSpace.bicep' = {
//   scope:  resourceGroup(ResourceGroup.id)
//   name: 'Build LogAnalyticsWorkSpace'
//   params: {
//     ApplicationName: ApplicationName
//     Environment: Environment
//     Location: Location
//     WorkloadName: WorkloadName
//   }
// }

output ResourceGroupName string = ResourceGroup.name
output ResourceGroupID string = ResourceGroup.id
