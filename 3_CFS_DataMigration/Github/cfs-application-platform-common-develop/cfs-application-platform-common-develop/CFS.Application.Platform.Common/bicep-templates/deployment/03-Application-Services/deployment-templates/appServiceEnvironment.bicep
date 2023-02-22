param resourceGroupName string

param aseName string
param location string
param dedicatedHostCount int
param zoneRedundant bool
param virtualNetworkSubscriptionId string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param subnetAddress string
param ilbMode int

@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountSubscriptionId string
param storageAccountName string
param workspaceResourceGroup string
param workspaceSubscriptionId string
param workspaceName string

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)


resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
  scope: subscription()
}

resource virtualNetwork_resource 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

module appServiceEnvironment_resource '../../../modules/Microsoft.Web/appServiceEnvironment.bicep' = {
  name: 'appServiceEnvironmentDeployment'
  params: {
    aseName: aseName
    location: location
    dedicatedHostCount: dedicatedHostCount
    zoneRedundant: zoneRedundant
    virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
    virtualNetworkName: virtualNetworkName
    subnetAddress: subnetAddress
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    subnetName: subnetName
    ilbMode: ilbMode
    storageAccountId: storageAccountId
    workspaceId: workspaceId
  }
}
