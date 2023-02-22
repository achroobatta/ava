targetScope = 'subscription'

param keyVaultObject object
param azureTenantId string
param storageAccountSubscriptionId string
param workspaceSubscriptionId string
@secure()
param localAdminPassword string

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

param servicesRequiringAbbreviationForKeyVaultName array = [
	'connectivity'
	'operations'
]

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in keyVaultObject.keyVault: {
  name: 'rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
  location: rg.location
  tags: {
    appName: rg.appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

@batchSize(1)
module keyVault '../../modules/Microsoft.KeyVault/deployKeyVault.bicep' = [for rg in keyVaultObject.keyVault: {
  name: 'kvdeploy-kv-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${ contains(servicesRequiringAbbreviationForKeyVaultName, rg.service) ? rg.serviceAbbrv : rg.service}'
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  params: {
    keyVaultName: 'kv-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${ contains(servicesRequiringAbbreviationForKeyVaultName, rg.service) ? rg.serviceAbbrv : rg.service}'
    azureTenantId: azureTenantId
    keyVaultResourceGroupLocation: rg.location
    keyVaultObject: rg
    storageAccountSubscriptionId: storageAccountSubscriptionId 
    storageAccountResourceGroup: 'rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-sec-stor-00${rg.instance}'
    storageAccountName: 'sto${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }diagnlogs00${rg.StorageAccountInstance}'
    workspaceResourceGroup: 'rg-${environmentPrefix}-${(rg.workspaceLocation == 'australiaeast') ? 'edc' : 'sdc' }-sec-sec-00${rg.instance}'
    workspaceSubscriptionId: workspaceSubscriptionId 
    workspaceName: 'ws-${environmentPrefix}-${(rg.workspaceLocation == 'australiaeast') ? 'edc' : 'sdc' }-00${rg.instance}'
    appName: rg.appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    localAdminPasswordSecretName: rg.localAdminPasswordSecretName
    localAdminPassword: localAdminPassword
    vaultkeyEncryptName: rg.vaultkeyEncryptName
  }
  dependsOn: [
    rgDeploy
  ]
}]
