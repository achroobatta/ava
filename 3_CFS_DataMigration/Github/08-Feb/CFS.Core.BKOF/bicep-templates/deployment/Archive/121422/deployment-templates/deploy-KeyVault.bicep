targetScope = 'subscription'

param keyVaultObject object
param azureTenantId string

param environmentPrefix string

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

param servicesRequiringAbbreviationForKeyVaultName array = [
	'connectivity'
	'operations'
]

@batchSize(1)
module keyVault '../../modules/Microsoft.KeyVault/deployKeyVault.bicep' = [for rg in keyVaultObject.keyVault: {
  name: 'kvdeploy-kv-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${ contains(servicesRequiringAbbreviationForKeyVaultName, rg.service) ? rg.serviceAbbrv : rg.service}-00${rg.instance}'
  scope: resourceGroup(rg.rgname)
  params: {
    keyVaultName: rg.kvName
    azureTenantId: azureTenantId
    keyVaultResourceGroupLocation: rg.location
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_kv.bicep' = [for rg in keyVaultObject.keyVault: {
  scope: resourceGroup(rg.rgname)
  name: 'pekvdeploy-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}' 
  params: {
    location: rg.location
    kvName: rg.kvName
    subnetName: rg.subnetName
    virtualNetworkName: rg.virtualNetworkName
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    kvRG: rg.kvRG
  }
  dependsOn: [
    keyVault
  ]
}]

module privateendpointforstorage2Deploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_kv.bicep' = [for rg in keyVaultObject.keyVault: {
  scope: resourceGroup(rg.rgname2)
  name: 'pekvdeploy-${environmentPrefix}-${(rg.location2 == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}' 
  params: {
    location: rg.location2
    kvName: rg.kvName
    subnetName: rg.subnet2Name
    virtualNetworkName: rg.virtualNetwork2Name
    virtualNetworkResourceGroup: rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    kvRG: rg.kvRG
  }
  dependsOn: [
    keyVault
  ]
}]
