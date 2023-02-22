param nsgName string
param nsgId string
param location string
param workspaceId string
param storageAccountId string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

var NetworkWatcherName = 'NetworkWatcher_${location}'
var FlowLogName = 'flowlog-${nsgName}'

resource NetworkWatcherName_FlowLogName 'Microsoft.Network/networkWatchers/FlowLogs@2019-11-01' = {
  name: '${NetworkWatcherName}/${FlowLogName}'
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    targetResourceId: nsgId
    storageId: storageAccountId
    enabled: true
    retentionPolicy: {
      days: 90
      enabled: true
    }
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: workspaceId
        trafficAnalyticsInterval: 60
      }
    }
  }
}
