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

param resourceLocation string
param diagStorageAcctName string
param privateEndpointNameForStorage string

@batchSize(1)
module storageAccount '../../modules/Microsoft.Storage/deployDiagStorageAccount.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'deploy${diagStorageAcctName}'
  scope: resourceGroup((resourceLocation == 'australiaeast') ? rg.rgname: rg.rgname2)
  params: {
    location: (resourceLocation == 'australiaeast') ? rg.location : rg.location2
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    //containerPrefix: rg.containerPrefix
    storageAccountName: diagStorageAcctName
    publicNetworkAccess: rg.publicNetworkAccess
    minimumTlsVersion: rg.minimumTlsVersion
    allowBlobPublicAccess: rg.allowBlobPublicAccess
    defaultAction: rg.defaultAction      
    performance: rg.performance
    kind: rg.kind
  }
}]

@batchSize(1)
module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_diagstorage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup((resourceLocation == 'australiaeast') ? rg.rgname: rg.rgname2)
  name: 'pvedeploy-${privateEndpointNameForStorage}'
  params: {
    location: (resourceLocation == 'australiaeast') ? rg.location : rg.location2
    storageName: diagStorageAcctName
    subnetName: (resourceLocation == 'australiaeast') ? rg.subnetName : rg.subnet2Name
    virtualNetworkName: (resourceLocation == 'australiaeast') ? rg.virtualNetworkName : rg.virtualNetwork2Name
    virtualNetworkResourceGroup: (resourceLocation == 'australiaeast') ? rg.virtualNetworkResourceGroup : rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
    storageRG: rg.rgname    
    privateEndpointNameForStorage: privateEndpointNameForStorage
  }
  dependsOn: [
    storageAccount
  ]
}]

// @batchSize(1)
// module privateendpoint2forstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_storage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
//   scope: resourceGroup(rg.rgname2)
//   name: 'pvedeploy-${rg.stoprefix}-${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
//   params: {
//     location: rg.location2
//     storageName: rg.storageAccountName
//     subnetName: rg.subnet2Name
//     virtualNetworkName: rg.virtualNetwork2Name
//     virtualNetworkResourceGroup: rg.virtualNetwork2ResourceGroup
//     privateDnsZoneName: rg.privateDnsZoneName
//     appName: appName
//     costCenter: costCenter
//     createOnDate: createOnDate
//     owner: owner
//     environmentPrefix: environmentPrefix
//     storageRG: rg.rgname
//     component: rg.component
//     instance: rg.instance
//     locationAbbrv: rg.locationAbbrv
//     serviceAbbrv: rg.serviceAbbrv
//     stoprefix: rg.stoprefix

//   }
//   dependsOn: [
//     storageAccount
//   ]
// }]
