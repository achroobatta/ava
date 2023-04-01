@description('Parameter for VNET object')
param vnetObject object

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

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

// TODO: this information belongs as a property on the subnet entity
var subnetRTOnly = [
  'GatewaySubnet'
  'AzureFirewallSubnet'
]

var subnetNSGOnly = [
  'AzureBastionSubnet'
]

var specialSubnet = [
  'GatewaySubnet'
  'AzureBastionSubnet'
  'AzureFirewallSubnet'
  'AzureFirewallManagementSubnet'
  'SDWANPeeringAddresses1'
  'SDWANPeeringAddresses2'
]

@batchSize(1)
module routeTableDeploy '../routeTables/deployRouteTable.bicep' = [for (snet,i) in vnetObject.subnets: if (contains(subnetRTOnly, snet.name)) {
  name: 'rt-only-${snet.routeTable}-${i}'
  params: {
    rtName: 'rt-${snet.name}'
    disableBGPProp: false
    routes: snet.routes
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

@batchSize(1)
module nsgOnlyDeploy '../NetworkSecurityGroups/deployBastionNSG.bicep' = [for (snet,i) in vnetObject.subnets: if (contains(subnetNSGOnly, snet.name)) {
  name: 'nsg-only-${snet.networkSecurityGroup}-${i}'
  params: {
    nsgName: 'nsg-${snet.name}'
    location: vnetObject.location
    workspaceId: workspaceId
    storageAccountId: storageAccountId
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

@batchSize(1)
module otherRouteTableDeploy '../routeTables/deployRouteTable.bicep' = [for (snet,i) in vnetObject.subnets: if (!contains(specialSubnet, snet.name)) {
  name: 'other-rt-${snet.routeTable}-${i}'
  params: {
    rtName: 'rt-${environmentPrefix}-${(snet.location == 'australiaeast') ? 'edc' : 'sdc' }-${snet.service}-00${snet.instance}'
    disableBGPProp: true
    routes: snet.routes
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

@batchSize(1)
module otherNsgDeploy '../NetworkSecurityGroups/deployNSG.bicep' = [for (snet,i) in vnetObject.subnets: if (!contains(specialSubnet, snet.name)) {
  name: 'other-nsg-${snet.networkSecurityGroup}-${i}'
  params: {
    nsgName: 'nsg-${environmentPrefix}-${(snet.location == 'australiaeast') ? 'edc' : 'sdc' }-${snet.service}-00${snet.instance}'
    location: vnetObject.location
    environmentPrefix: environmentPrefix
    workspaceId: workspaceId
    storageAccountId: storageAccountId
    appName: appName
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  dependsOn: [
    otherRouteTableDeploy
  ]
}]
