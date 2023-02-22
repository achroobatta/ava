targetScope = 'subscription'

param environmentPrefix string
param resourceGroupObject object

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

// param warrantyPeriod int
// var wp = 'P${warrantyPeriod}M'
// var dBD = dateTimeAdd(australiaEastNowFormatted, wp)
// var deleteByDate = dateTimeAdd(dBD, 'P15D')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

@description('The string value for appName tag')
param appName string

param resourceLocation string
param dlstorageAccountName string
// param dlRootContainterName string
param connSubId string
param connRg string
param rgName string

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
}]
