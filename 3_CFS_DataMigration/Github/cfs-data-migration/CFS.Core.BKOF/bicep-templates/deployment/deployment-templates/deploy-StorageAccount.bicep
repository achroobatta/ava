targetScope = 'subscription'

//param from parameter file
param resourceGroupObject object

//param from pipeline
param environmentPrefix string
param connSubId string
param connRg string
param rgName string
param resourceLocation string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

@description('The string value for appName tag')
param appName string

@batchSize(1)
module storageAccount '../../modules/Microsoft.Storage/deployStorageAccount.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: '${rg.stoprefix}${environmentPrefix}${(resourceLocation == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  scope: resourceGroup(rgName)
  params: {
    location: resourceLocation
    storageAccount: (resourceLocation == 'australiaeast') ? rg.storageAccount : rg.storage2Account
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    virtualNetworkResourceGroup: (resourceLocation == 'australiaeast') ? rg.virtualNetworkResourceGroup :rg.virtualNetwork2ResourceGroup
    virtualNetworkName_RG: (resourceLocation == 'australiaeast') ? rg.virtualNetworkName_RG : rg.virtualNetwork2Name_RG
    virtualNetworksubnetName: (resourceLocation == 'australiaeast') ? rg.virtualNetworksubnetName : rg.virtualNetwork2subnetName
    containerPrefix: rg.containerPrefix
  }
}]

@batchSize(1)
module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_storage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup(rgName)
  name: 'pvedeploy-${rg.stoprefix}-${environmentPrefix}${(resourceLocation == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: resourceLocation
    storageName: (resourceLocation == 'australiaeast') ? rg.storageAccountName : rg.storage2AccountName
    subnetName: (resourceLocation == 'australiaeast') ? rg.subnetName : rg.subnet2Name
    virtualNetworkName: (resourceLocation == 'australiaeast') ? rg.virtualNetworkName : rg.virtualNetwork2Name
    virtualNetworkResourceGroup: (resourceLocation == 'australiaeast') ? rg.virtualNetworkResourceGroup : rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
    storageRG: rgName
    component: rg.component
    instance: rg.instance
    locationAbbrv: (resourceLocation == 'australiaeast') ? 'edc' : 'sdc'
    serviceAbbrv: rg.serviceAbbrv
    stoprefix: rg.stoprefix
    connSubId: connSubId
    connRg: connRg
  }
  dependsOn: [
    storageAccount
  ]
}]
