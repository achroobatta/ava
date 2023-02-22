param location string
param nsgName string
param workspaceId string
param storageAccountId string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

resource nsg  'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}

module deployFlowLogs '../NetworkSecurityGroups/enableFlowLogs.bicep' = {
  name: 'deployFlowLogs'
  scope: resourceGroup('NetworkWatcherRG')
  params: {
    location: location
    nsgName: nsg.name
    nsgId: nsg.id
    workspaceId: workspaceId
    storageAccountId: storageAccountId
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}
