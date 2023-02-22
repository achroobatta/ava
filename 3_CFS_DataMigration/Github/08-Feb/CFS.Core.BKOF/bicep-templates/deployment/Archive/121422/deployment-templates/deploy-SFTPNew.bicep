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

param sftpstorageAccountName string
param sftpRootContainterName string
param sftpUserName string
param sshKeyName string

// param sftpWhiteListip string
param ipTobeWhiteListed string

var sftpWhiteListedIps = split(ipTobeWhiteListed,',')

param resourceLocation string

//var contributorRoleDefId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@batchSize(1)
module storageAccount '../../modules/Microsoft.Storage/deploysftpnew.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'sftpsto${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  scope: resourceGroup(rg.rgname)
  //scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  params: {
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    deleteByDate: deleteByDate
    sftplocation: rg.location
    sftpUserName: sftpUserName
    sftpstorageAccountName: sftpstorageAccountName
    sftpRootContainterName: sftpRootContainterName
    sshKeyName: sshKeyName
    sftpWhiteListedIps: sftpWhiteListedIps
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    virtualNetworkName_RG: rg.virtualNetworkRGName
    virtualNetworksubnetName: rg.virtualNetworksubnetName
    ipRulesaction: rg.ipRulesaction
    virtualNetworkRulesaction: rg.virtualNetworkRulesaction
    defaultAction: rg.defaultAction
    publicNetworkAccess: rg.publicNetworkAccess
    minimumTlsVersion: rg.minimumTlsVersion
    allowBlobPublicAccess: rg.allowBlobPublicAccess
    supportsHttpsTrafficOnly: rg.supportsHttpsTrafficOnly
    allowSharedKeyAccess: rg.allowSharedKeyAccess
    isSftpEnabled: rg.isSftpEnabled
    isHnsEnabled: rg.isHnsEnabled
    largeFileSharesState: rg.largeFileSharesState
    isNfsV3Enabled: rg.isNfsV3Enabled
    performance: rg.performance
    kind: rg.kind
  }
}]

@batchSize(1)
module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_storage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup((resourceLocation == 'australiaeast') ? rg.rgname: rg.rgname2)
  name: 'pvedeploy-${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: (resourceLocation == 'australiaeast') ? rg.location : rg.location2
    storageName: sftpstorageAccountName
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
