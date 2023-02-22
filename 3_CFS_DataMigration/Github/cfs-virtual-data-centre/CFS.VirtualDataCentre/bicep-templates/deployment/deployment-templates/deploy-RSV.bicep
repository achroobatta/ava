targetScope = 'subscription'

param resourceGroupObject object
param storageAccountSubscriptionId string
param workspaceSubscriptionId string
param environmentPrefix string

param subscriptionId string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

var backupPolicyJson = json(loadTextContent('../backupPolicy.param.json'))

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in resourceGroupObject.resourceGroups: {
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

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'AzureBackupRG_${rg.location}_1'
  location: rg.location
  tags: {
    appName: rg.appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  managedBy: 'subscriptions/${subscriptionId}/providers/Microsoft.RecoveryServices/'
}]

@batchSize(1)
module rsvDeploy '../../modules/Microsoft.RecoveryServices/vaults/deployRSV.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'rsv-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.service}-00${rg.instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  params: {
    rsvName: 'rsv-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.service}-00${rg.instance}'
    location: rg.location
    storageAccountSubscriptionId: storageAccountSubscriptionId
    storageAccountResourceGroup: 'rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-sec-stor-00${rg.instance}'
    storageAccountName: 'sto${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }diagnlogs00${rg.StorageAccountInstance}'
    workspaceSubscriptionId: workspaceSubscriptionId
    workspaceResourceGroup: 'rg-${environmentPrefix}-${(rg.workspaceLocation == 'australiaeast') ? 'edc' : 'sdc' }-sec-sec-00${rg.instance}'
    workspaceName: 'ws-${environmentPrefix}-${(rg.workspaceLocation == 'australiaeast') ? 'edc' : 'sdc' }-00${rg.instance}'
    appName: rg.appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  dependsOn: [
    rgDeploy
  ]
}]


@batchSize(1)
module policyDeploy '../../modules/Microsoft.RecoveryServices/vaults/deployBackupPolicy.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'policy-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.service}-00${rg.instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  params: {
    rsvName: 'rsv-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.service}-00${rg.instance}'
    backupPolicy: backupPolicyJson.backupPolicy
  }
  dependsOn: [
    rsvDeploy
  ]
}]
