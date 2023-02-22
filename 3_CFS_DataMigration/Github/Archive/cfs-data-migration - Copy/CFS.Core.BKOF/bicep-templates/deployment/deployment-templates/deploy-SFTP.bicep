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

//var contributorRoleDefId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@batchSize(1)
module storageAccount '../../modules/Microsoft.Storage/deploysftp.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'sftpsto${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  scope: resourceGroup(rg.rgname)
  //scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  params: {
    appName: rg.appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    storageAccount: rg.storageAccount
    sftplocation: rg.location
  }
}]

@batchSize(1)
module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_storage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup(rg.rgname)
  name: 'pvedeploy-${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: rg.location
    storageName: rg.sftpstorageAccountName
    subnetName: rg.subnetName
    virtualNetworkName: rg.virtualNetworkName
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: rg.appName
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
  name: 'pvedeploy-${environmentPrefix}${(rg.location2 == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: rg.location2
    storageName: rg.sftpstorageAccountName
    subnetName: rg.subnet2Name
    virtualNetworkName: rg.virtualNetwork2Name
    virtualNetworkResourceGroup: rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: rg.appName
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
