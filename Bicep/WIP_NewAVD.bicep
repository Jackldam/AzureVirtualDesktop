@description('Required, Workload name')
param WorkloadName string

@description('Required, Application name')
param ApplicationName string

@description('Optional, Location')
param Location string = resourceGroup().location

@description('Required, Environment as per DTAP principal')
@allowed([ 'd', 't', 'a', 'p' ])
param Environment string

var HostPoolName = '${WorkloadName}-${ApplicationName}-${Location}-${Environment}-hp'
var ApplicationGroupName = '${WorkloadName}-${ApplicationName}-${Location}-${Environment}-ag'
var WorkSpaceName = '${WorkloadName}-${ApplicationName}-${Location}-${Environment}-ws'
var LogAnalyticsWorkspaceName = '${WorkloadName}-${ApplicationName}-${Location}-${Environment}-laws'

resource vm virtual
