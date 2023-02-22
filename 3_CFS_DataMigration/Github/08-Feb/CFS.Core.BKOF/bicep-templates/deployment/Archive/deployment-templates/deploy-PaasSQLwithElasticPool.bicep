targetScope = 'subscription'

param environmentPrefix string

param appName string
param serviceAbbrv string
param instance string
param component string
param sqlRG string
// param subscriptionId string

param privateDnsZoneName string

param rgname string
param location string
param subnetName string
param virtualNetworkName string
param virtualNetworkResourceGroup string

param rgname2 string
param location2 string
param subnet2Name string
param virtualNetwork2Name string
param virtualNetwork2ResourceGroup string

//param databaseName string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

@description('Parameters for SQL Server')
param administratorLogin string
@secure()
param administratorLoginPassword string
param sqlServerName string

@description('Parameters for Elastic Pool')
param elasticPoolName string
param skuName string
param tier string
param poolLimit int
param minCapacity int
param maxCapacity int
param poolSize int
param zoneRedundant bool
param licenseType string

@description('Parameters for SQL Database')
param databaseName string
param sqlDbTierName string

@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountSubscriptionId string
param storageAccountName string
param workspaceResourceGroup string
param workspaceSubscriptionId string
param workspaceName string

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

module sqlServerDeployment '../../modules/Microsoft.Sql/sql.server.bicep' = {
  scope: resourceGroup(rgname)
  name: 'sqlsrvdeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
  params: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    sqlServerName: sqlServerName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
  }
}

module elasticPoolDeployment '../../modules/Microsoft.Sql/sql.elasticPool.bicep' = {
  scope: resourceGroup(rgname)
  name: 'ElasticPoolDeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
  params: {
    sqlServerName: sqlServerName
    elasticPoolName: elasticPoolName
    location: location
    skuName: skuName
    tier: tier
    poolLimit: poolLimit
    minCapacity: minCapacity
    maxCapacity: maxCapacity
    poolSize: poolSize
    zoneRedundant: zoneRedundant
    licenseType: licenseType
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    storageAccountId: storageAccountId
    workspaceId: workspaceId
  }
  dependsOn: [
    sqlServerDeployment
  ]
}

module databaseDeployment '../../modules/Microsoft.Sql/sql.database.bicep' = {
  scope: resourceGroup(rgname)
  name: 'dBdeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
  params: {
    elasticPoolName: elasticPoolName
    elasticPoolResourceGroup: rgname
    sqlServerName: sqlServerName
    databaseName: databaseName
    location: location
    sqlDbTierName: sqlDbTierName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    storageAccountId: storageAccountId
    workspaceId: workspaceId
    workspaceSubscriptionId: workspaceSubscriptionId
    workspaceResourceGroup: workspaceResourceGroup

  }
  dependsOn: [
    sqlServerDeployment
    elasticPoolDeployment
  ]
}

module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_sql.bicep' = {
  scope: resourceGroup(rgname)
  name: 'pesqldeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-${component}-00${instance}' 
  params: {
    location: location
    sqlServerName: sqlServerName
    subnetName: subnetName
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privateDnsZoneName: privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    sqlRG: sqlRG
  }
  dependsOn: [
    sqlServerDeployment
    elasticPoolDeployment
    databaseDeployment
  ]
}

module privateendpointforstorage2Deploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_sql.bicep' = {
  scope: resourceGroup(rgname2)
  name: 'pesqldeploy-${environmentPrefix}-${(location2 == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-${component}-00${instance}' 
  params: {
    location: location2
    sqlServerName: sqlServerName
    subnetName: subnet2Name
    virtualNetworkName: virtualNetwork2Name
    virtualNetworkResourceGroup: virtualNetwork2ResourceGroup
    privateDnsZoneName: privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    sqlRG: sqlRG
  }
  dependsOn: [
    sqlServerDeployment
    elasticPoolDeployment
    databaseDeployment
  ]
}
