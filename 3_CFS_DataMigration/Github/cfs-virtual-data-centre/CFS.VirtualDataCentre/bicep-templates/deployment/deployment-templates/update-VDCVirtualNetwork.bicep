targetScope = 'subscription'

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
param owner string
param costCenter string
param environmentPrefix string
param storageAccountSubscriptionId string
param workspaceSubscriptionId string
param virtualNetworkObject object

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in virtualNetworkObject.virtualNetwork: {
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
module vnetDeploy '../../modules/Microsoft.Network/virtualNetwork/updateVNET.bicep' = [for rg in virtualNetworkObject.virtualNetwork: {
  name: 'vnet-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${(rg.service == 'connectivity') ? 'hub' : rg.service}-00${rg.instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  params: {
    vnetObject: rg
    vnetName: 'vnet-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${(rg.service == 'connectivity') ? 'hub' : rg.service}-00${rg.instance}'
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
  }
  dependsOn: rgDeploy
}]
