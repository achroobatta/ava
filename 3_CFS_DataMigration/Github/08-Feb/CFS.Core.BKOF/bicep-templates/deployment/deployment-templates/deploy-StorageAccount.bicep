targetScope = 'subscription'

param environmentPrefix string
param resourceGroupObject object

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
  name: '${rg.stoprefix}${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  scope: resourceGroup(rg.rgname)
  params: {
    location: rg.location
    storageAccount: rg.storageAccount
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    virtualNetworkName_RG: rg.virtualNetworkName_RG
    virtualNetworksubnetName: rg.virtualNetworksubnetName
    containerPrefix: rg.containerPrefix   
  }
}]

@batchSize(1)
module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_storage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup(rg.rgname)
  name: 'pvedeploy-${rg.stoprefix}-${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: rg.location
    storageName: rg.storageAccountName
    subnetName: rg.subnetName
    virtualNetworkName: rg.virtualNetworkName
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
    storageRG: rg.rgname
    component: rg.component
    instance: rg.instance
    locationAbbrv: rg.locationAbbrv
    serviceAbbrv: rg.serviceAbbrv
    stoprefix: rg.stoprefix

  }
  dependsOn: [
    storageAccount
  ]
}]

@batchSize(1)
module privateendpoint2forstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_storage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup(rg.rgname2)
  name: 'pvedeploy-${rg.stoprefix}-${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: rg.location2
    storageName: rg.storageAccountName
    subnetName: rg.subnet2Name
    virtualNetworkName: rg.virtualNetwork2Name
    virtualNetworkResourceGroup: rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
    storageRG: rg.rgname
    component: rg.component
    instance: rg.instance
    locationAbbrv: rg.locationAbbrv
    serviceAbbrv: rg.serviceAbbrv
    stoprefix: rg.stoprefix

  }
  dependsOn: [
    storageAccount
  ]
}]
