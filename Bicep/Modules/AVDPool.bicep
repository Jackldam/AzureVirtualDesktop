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

resource HostPool 'Microsoft.DesktopVirtualization/hostPools@2022-10-14-preview' = {
  name: HostPoolName
  location: Location
  properties: {
    hostPoolType: 'Personal'
    loadBalancerType: 'Persistent'
    preferredAppGroupType: 'Desktop'
    agentUpdate: {
      type: 'Scheduled'
      maintenanceWindows: [
        {
          dayOfWeek: 'Sunday'
          hour: 00
        }
      ]
      maintenanceWindowTimeZone: 'W. Europe Standard Time'
      useSessionHostLocalTime: false
    }
    maxSessionLimit: 9999
    publicNetworkAccess: 'Disabled'
    startVMOnConnect: true
    registrationInfo: {
      registrationTokenOperation: 'Update'
    }
    customRdpProperty: '#TODO'
    personalDesktopAssignmentType: 'Automatic'
  }
}

resource ApplicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2022-10-14-preview' = {
  name: ApplicationGroupName
  properties: {
    applicationGroupType: 'Desktop'
    hostPoolArmPath: HostPool.id
  }
}

resource WorkSpace 'Microsoft.DesktopVirtualization/workspaces@2022-10-14-preview' = {
  name: WorkSpaceName
  location: Location
  properties: {
    applicationGroupReferences: [ApplicationGroup.id]
    description: '#TODO'
    friendlyName: '#TODO'
    publicNetworkAccess:'Disabled'
  }
}

resource LogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: LogAnalyticsWorkspaceName
  location: Location
  properties: {
    retentionInDays: 30
    features: {
      immediatePurgeDataOn30Days: true 
    }
    sku: {
      name: 'Free'
    }
  }
}

resource diagnosticLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: LogAnalyticsWorkspace.name
  scope: HostPool
  properties: {
    workspaceId: LogAnalyticsWorkspace.id
    logs: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true 
        }
      }
    ]
  }
}
