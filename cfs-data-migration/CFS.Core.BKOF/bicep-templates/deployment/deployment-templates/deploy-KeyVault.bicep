targetScope = 'subscription'

//parameters from parameter file
param keyVaultObject object

//parameters passed from pipeline
param azureTenantId string
param connSubId string
param connRg string
param rgName string
param resourceLocation string

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

param storageAccountSubscriptionId string
param workspaceSubscriptionId string

@batchSize(1)
module keyVault '../../modules/Microsoft.KeyVault/deployKeyVault.bicep' = [for rg in keyVaultObject.keyVault: {
  name: 'kvdeploy-kv-${environmentPrefix}-${(resourceLocation == 'australiaeast') ? 'edc' : 'sdc' }-${ contains(servicesRequiringAbbreviationForKeyVaultName, rg.service) ? rg.serviceAbbrv : rg.service}-00${rg.instance}'
  scope: resourceGroup(rgName)
  params: {
    keyVaultName: (resourceLocation == 'australiaeast') ? rg.kvName : rg.kv2Name
    azureTenantId: azureTenantId
    keyVaultResourceGroupLocation: resourceLocation
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    virtualNetworkResourceGroup: (resourceLocation == 'australiaeast') ? rg.virtualNetworkResourceGroup : rg.virtualNetwork2ResourceGroup
    virtualNetworkName: (resourceLocation == 'australiaeast') ? rg.virtualNetworkName : rg.virtualNetwork2Name
    virtualNetworksubnetName: (resourceLocation == 'australiaeast') ? rg.virtualNetworksubnetName : rg.virtualNetworksubnet2Name
    defaultAction: rg.defaultAction
    enabledForDeployment: rg.enabledForDeployment
    enabledForDiskEncryption: rg.enabledForDiskEncryption
    enabledForTemplateDeployment: rg.enabledForTemplateDeployment
    enableSoftDelete: rg.enableSoftDelete
    enablePurgeProtection: rg.enablePurgeProtection
    enableRbacAuthorization: rg.enableRbacAuthorization
    publicNetworkAccess: rg.publicNetworkAccess
    storageAccountSubscriptionId: storageAccountSubscriptionId
    storageAccountResourceGroup: 'rg-${environmentPrefix}-${(resourceLocation == 'australiaeast') ? 'edc' : 'sdc' }-sec-stor-00${rg.StorageAccountRgInstance}'
    storageAccountName: 'sto${environmentPrefix}${(resourceLocation == 'australiaeast') ? 'edc' : 'sdc' }diagnlogs00${rg.StorageAccountInstance}'
    workspaceResourceGroup: 'rg-${environmentPrefix}-${(resourceLocation == 'australiaeast') ? 'edc' : 'sdc' }-sec-sec-00${rg.workspaceRgInstance}'
    workspaceSubscriptionId: workspaceSubscriptionId
    workspaceName: 'ws-${environmentPrefix}-${(resourceLocation == 'australiaeast') ? 'edc' : 'sdc' }-00${rg.workspaceInstance}'
    virtualNetworkRules: (resourceLocation == 'australiaeast') ? rg.virtualNetworkRules : rg.virtualNetwork2Rules
    action: rg.action
  }
}]

module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_kv.bicep' = [for rg in keyVaultObject.keyVault: {
  scope: resourceGroup(rgName)
  name: 'pekvdeploy-${environmentPrefix}-${(resourceLocation == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
  params: {
    location: resourceLocation
    kvName: (resourceLocation == 'australiaeast') ? rg.kvName : rg.kv2Name
    subnetName: (resourceLocation == 'australiaeast') ? rg.subnetName : rg.subnet2Name
    virtualNetworkName: (resourceLocation == 'australiaeast') ? rg.virtualNetworkName : rg.virtualNetwork2Name
    virtualNetworkResourceGroup: (resourceLocation == 'australiaeast') ? rg.virtualNetworkResourceGroup: rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    kvRG: (resourceLocation == 'australiaeast') ? rg.kvRG : rg.kv2RG
    connSubId: connSubId
    connRg: connRg
  }
  dependsOn: [
    keyVault
  ]
}]
