@description('Parameter for VNET object')
param vnetObject object
param vnetName string


@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountSubscriptionId string
param storageAccountName string
param workspaceResourceGroup string
param workspaceSubscriptionId string
param workspaceName string


@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

// find the existing virtual network
resource vnetExisting 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: vnetName
}

module virtualNetwork './deployVNET.bicep' = {
  name: 'update-${vnetName}'
  params: {
    vnetObject: vnetObject
    vnetName: vnetName
    vnetPeerings: vnetExisting.properties.virtualNetworkPeerings
    storageAccountSubscriptionId: storageAccountSubscriptionId
    storageAccountResourceGroup: storageAccountResourceGroup
    storageAccountName: storageAccountName
    workspaceResourceGroup: workspaceResourceGroup
    workspaceSubscriptionId: workspaceSubscriptionId
    workspaceName: workspaceName
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}


