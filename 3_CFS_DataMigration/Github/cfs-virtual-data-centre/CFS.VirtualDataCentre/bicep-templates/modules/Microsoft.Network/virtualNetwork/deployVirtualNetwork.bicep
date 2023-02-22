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

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)


resource vnetDeploy 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: vnetObject.location
  properties: {
    addressSpace: {
      addressPrefixes: vnetObject.addressSpaces
    }
    dhcpOptions: {
      dnsServers: vnetObject.customDnsServers
    }
  }
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${vnetDeploy.name}'
  scope: vnetDeploy
  properties: {
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
    ]
    storageAccountId: storageAccountId
    workspaceId: workspaceId
  }
}
/*
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
]

@batchSize(1)
module routeTableDeploy '../routeTables/deployRouteTable.bicep' = [for snet in vnetObject.subnets: if (contains(subnetRTOnly, snet.name)) {
  name: 'rt-${snet.name}'
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
  dependsOn: [
    vnetDeploy
  ]
}]

@batchSize(1)
module subnetRTOnlyDeploy '../subnet/deploySubnetWithRT.bicep' = [for snet in vnetObject.subnets: if (contains(subnetRTOnly, snet.name)) {
  name: 'subnetRTOnly-sub-${snet.name}'
  params: {
    vNetName: vnetDeploy.name
    subnetName: snet.name
    subnetAddressPrefix: snet.subnetAddressSpace
    serviceEndPoints: snet.serviceEndPoints
  }
  dependsOn: [
    routeTableDeploy
  ]
}]

@batchSize(1)
module nsgOnlyDeploy '../NetworkSecurityGroups/deployBastionNSG.bicep' = [for snet in vnetObject.subnets: if (contains(subnetNSGOnly, snet.name)) {
  name: 'nsgOnlyDeploy-nsg-${snet.name}'
  params: {
    nsgName: 'nsg-${snet.name}'
    location: vnetObject.location
    vNetName: vnetDeploy.name
    subnetName: snet.name
    workspaceId: workspaceId
    storageAccountId: storageAccountId
    subnetAddressPrefix: snet.subnetAddressSpace
    serviceEndPoints: snet.serviceEndPoints
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

@batchSize(1)
module otherRouteTableDeploy '../routeTables/deployRouteTable.bicep' = [for snet in vnetObject.subnets: if (!contains(specialSubnet, snet.name)) {
  name: 'other-rt-${environmentPrefix}-${(vnetObject.location == 'australiaeast') ? 'edc' : 'sdc' }-${snet.name}'
  params: {
    rtName: 'rt-${environmentPrefix}-${(vnetObject.location == 'australiaeast') ? 'edc' : 'sdc' }-${snet.name}'
    disableBGPProp: true
    routes: snet.routes
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  dependsOn: [
    vnetDeploy
  ]
}]

@batchSize(1)
module otherNsgDeploy '../NetworkSecurityGroups/deployNSG.bicep' = [for snet in vnetObject.subnets: if (!contains(specialSubnet, snet.name)) {
  name: 'other-nsg-${environmentPrefix}-${(vnetObject.location == 'australiaeast') ? 'edc' : 'sdc' }-${snet.name}'
  params: {
    nsgName: 'nsg-${environmentPrefix}-${(vnetObject.location == 'australiaeast') ? 'edc' : 'sdc' }-${snet.name}'
    location: vnetObject.location
    vNetName: vnetName
    subnetName: 'sub-${environmentPrefix}-${(vnetObject.location == 'australiaeast') ? 'edc' : 'sdc' }-${snet.name}'
    environmentPrefix: environmentPrefix
    workspaceId: workspaceId
    subnetSuffixName: snet.name
    storageAccountId: storageAccountId
    subnetAddressSpace: snet.subnetAddressSpace
    serviceEndPoints: snet.serviceEndPoints
    appName: appName
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  dependsOn: [
    vnetDeploy
    otherRouteTableDeploy
  ]
}]
*/
