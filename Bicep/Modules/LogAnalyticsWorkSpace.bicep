@description('Required, Workload name')
param WorkloadName string

@description('Required, Application name')
param ApplicationName string

@description('Optional, Location')
param Location string

@description('Required, Environment as per DTAP principal')
@allowed([ 'd', 't', 'a', 'p' ])
param Environment string

var LogAnalyticsWorkspaceName = '${WorkloadName}-${ApplicationName}-${Location}-${Environment}-laws'

resource LogAnalyticsWorkspace 'Microsoft.Monitor/accounts@2021-06-03-preview' = {
  name: LogAnalyticsWorkspaceName
  location: Location
}
