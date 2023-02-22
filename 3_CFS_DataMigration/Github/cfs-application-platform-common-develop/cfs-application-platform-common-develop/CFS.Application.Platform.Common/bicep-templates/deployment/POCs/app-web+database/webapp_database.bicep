param subscriptionId string
param resourceGroupName string

param webAppDBObject object
param name string

var vnetName = '${name}Vnet'
var privateEndpointSubnet = '${name}Subnet'
var subnetForApp = 'app-subnet'
var privateEndpointNameForApp = '${name}AppEndpoint'
var privateEndpointNameForDb = '${name}DbEndpoint'
var privateDnsZoneNameForApp = 'privatelink.azurewebsites.net'
var privateDnsZoneNameForDb = 'privatelink.database.windows.net'

var vnetResourcesDeployment_var = 'vnetResourcesDeployment'
var databaseResourcesDeployment_var = 'databaseResourcesDeployment'
var appServiceResourcesDeployment_var = 'appServiceResourcesDeployment'
var appServiceDatabaseConnectionResourcesDeployment_var = 'appServiceDatabaseConnectionResourcesDeployment'
var databaseVersion = '12.0'


resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
  scope: subscription()
}

module databaseResourcesDeployment './nested_databaseResourcesDeployment.bicep' = [for n in webAppDBObject.webAppDBValues:  {
  name: databaseResourcesDeployment_var
  params: {
    resourceId_Microsoft_Network_virtualNetworks_subnets_parameters_vnetName_parameters_privateEndpointSubnet: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnet)
    resourceId_Microsoft_Sql_servers_parameters_serverName: resourceId('Microsoft.Sql/servers/', n.serverName)
    resourceId_Microsoft_Network_privateDnsZones_parameters_privateDnsZoneNameForDb: resourceId('Microsoft.Network/privateDnsZones', privateDnsZoneNameForDb)
    variables_databaseResourcesDeployment: databaseResourcesDeployment_var
    variables_databaseVersion: databaseVersion
    isVnetEnabled: n.isVnetEnabled
    privateEndpointNameForDb: privateEndpointNameForDb
    location: rg.location
    serverName: n.serverName
    serverUsername: n.serverUsername
    serverPassword: n.serverPassword
    databaseName: n.databaseName
    collation: n.collation
    sqlDbSkuName: n.sqlDbSkuName
    sqlDbTierName: n.sqlDbTierName
    storageAccountName: n.storageAccountName
    storageAccountSubscriptionId: subscriptionId
  }
  dependsOn: [
    vnetResourcesDeployment
  ]
}]

module appServiceResourcesDeployment './nested_appServiceResourcesDeployment.bicep' = [for n in webAppDBObject.webAppDBValues: {
  name: appServiceResourcesDeployment_var
  params: {
    privateEndpointSubnet: privateEndpointSubnet
    variables_appServiceResourcesDeployment: appServiceResourcesDeployment_var
    variables_subnetAddressForApp: n.subnetAddressForApp
    hostingPlanName: n.hostingPlanName
    location: rg.location
    workerSize: n.workerSize
    workerSizeId: n.workerSizeId
    numberOfWorkers: n.numberOfWorkers
    sku: n.sku
    skuCode: n.skuCode
    name: name
    linuxFxVersion: n.linuxFxVersion
    subscriptionId: subscriptionId
    serverFarmResourceGroup: resourceGroupName
    isVnetEnabled: n.isVnetEnabled
    vnetName: vnetName
    subnetForApp: subnetForApp
    isPrivateEndpointForAppEnabled: n.isPrivateEndpointForAppEnabled
    privateEndpointNameForApp: privateEndpointNameForApp
    privateDnsZoneNameForApp: privateDnsZoneNameForApp
  }
  dependsOn: [
    databaseResourcesDeployment
    vnetResourcesDeployment
  ]
}]

module appServiceDatabaseConnectionResourcesDeployment './nested_appServiceDatabaseConnectionResourcesDeployment.bicep' = [for n in webAppDBObject.webAppDBValues: {
  name: appServiceDatabaseConnectionResourcesDeployment_var
  params: {
    name: name
    serverName: n.serverName
    serverUsername: n.serverUsername
    serverPassword: n.serverPassword
    databaseName: n.databaseName
  }
  dependsOn: [
    databaseResourcesDeployment
    appServiceResourcesDeployment
  ]
}]

module vnetResourcesDeployment './nested_vnetResourcesDeployment.bicep' = [for n in webAppDBObject.webAppDBValues: if (n.isVnetEnabled) {
  name: vnetResourcesDeployment_var
  params: {
    variables_vnetAddress: n.vnetAddress
    variables_subnetAddressForPrivateEndpoint: n.subnetAddressForPrivateEndpoint
    location: rg.location
    vnetName: vnetName
    privateEndpointSubnet: privateEndpointSubnet
    isPrivateEndpointForAppEnabled: n.isPrivateEndpointForAppEnabled
    privateDnsZoneNameForApp: privateDnsZoneNameForApp
    privateDnsZoneNameForDb: privateDnsZoneNameForDb
  }
}]
