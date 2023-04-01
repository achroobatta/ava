targetScope = 'subscription'

param environmentPrefix string
param resourceGroupObject object

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

param warrantyPeriod int
var wp = 'P${warrantyPeriod}M'
var dBD = dateTimeAdd(australiaEastNowFormatted, wp)
var deleteByDate = dateTimeAdd(dBD, 'P15D')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

@description('The string value for appName tag')
param appName string

param resourceLocation string
param rgName string
param dlstorageAccountName string
param dlRootContainterName string
param connSubId string
param connRg string

@batchSize(1)
module dlstorageAccount '../../modules/Microsoft.Storage/deploydatalakegen2.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'deploy-${dlstorageAccountName}-${rg.instance}'
  scope: resourceGroup(rgName)
  params: {
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    deleteByDate: deleteByDate
    owner: owner
    dllocation: resourceLocation
    environmentPrefix: environmentPrefix
    // virtualNetworkResourceGroup: (resourceLocation == 'australiaeast') ? rg.virtualNetworkResourceGroup : rg.virtualNetwork2ResourceGroup
    // virtualNetworkName_RG: (resourceLocation == 'australiaeast') ? rg.virtualNetworkName_RG : rg.virtualNetwork2Name_RG
    // virtualNetworksubnetName: (resourceLocation == 'australiaeast') ? rg.virtualNetworksubnetName : rg.virtualNetwork2subnetName
    action: rg.action
    defaultAction: rg.defaultAction
    publicNetworkAccess: rg.publicNetworkAccess
    minimumTlsVersion: rg.minimumTlsVersion
    allowBlobPublicAccess: rg.allowBlobPublicAccess
    supportsHttpsTrafficOnly: rg.supportsHttpsTrafficOnly
    allowSharedKeyAccess: rg.allowSharedKeyAccess
    isHnsEnabled: rg.isHnsEnabled
    largeFileSharesState: rg.largeFileSharesState
    isNfsV3Enabled: rg.isNfsV3Enabled
    performance: rg.performance
    kind: rg.kind
    dlstorageAccountName: dlstorageAccountName
    dlRootContainterName: dlRootContainterName
    dlWhiteListedIps: rg.dlWhiteListedIps
    virtualNetworkRules: (resourceLocation == 'australiaeast') ? rg.virtualNetworkRules : rg.virtualNetwork2Rules
  }
}]

@batchSize(1)
module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_deststorage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup(rgName)
  name: 'pvedeploy-${dlstorageAccountName}-${rg.instance}'
  params: {
    location: resourceLocation
    storageName: dlstorageAccountName
    subnetName: (resourceLocation == 'australiaeast') ? rg.subnetName : rg.subnet2Name
    virtualNetworkName: (resourceLocation == 'australiaeast') ? rg.virtualNetworkName : rg.virtualNetwork2Name
    virtualNetworkResourceGroup: (resourceLocation == 'australiaeast') ? rg.virtualNetworkResourceGroup : rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    storageAccountName: dlstorageAccountName
    owner: owner
    environmentPrefix: environmentPrefix
    storageRG: rgName
    connSubId: connSubId
    connRg: connRg
  }
  dependsOn: [
    dlstorageAccount
  ]
}]
