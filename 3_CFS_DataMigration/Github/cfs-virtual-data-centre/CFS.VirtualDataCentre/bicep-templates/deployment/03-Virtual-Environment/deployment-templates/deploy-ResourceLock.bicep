targetScope = 'subscription'

@description('The string value for owner tag')
param owner string
@description('Environment')
param environmentPrefix string
@description('Application Name')
param appName string

param rgArray array
var lockType = 'CanNotDelete'

module deloyResourceLock '../../../modules/Microsoft.Authorization/locks/deployResourceLock.bicep' = [for rg in rgArray : {
  name: 'deploylock-${rg.name}'
  scope: resourceGroup(rg.name)
  params: {
    resourceGroupName: rg.name
    lockType: lockType
  }
}]
