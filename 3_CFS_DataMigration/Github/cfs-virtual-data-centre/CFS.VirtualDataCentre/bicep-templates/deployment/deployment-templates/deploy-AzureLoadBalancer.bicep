targetScope = 'subscription'

param environmentPrefix string
param storageAccountSubscriptionId string
param workspaceSubscriptionId string
param loadBalancerObject object

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

@batchSize(1)
module azureLoadBalancerDeploy '../../modules/Microsoft.Network/loadBalancers/deployAzureLoadBalancer.bicep' = [for rg in loadBalancerObject.loadBalancer: {
  name: rg.loadBalancerName
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.rgInstance}')
  params: {
    loadBalancerObject: loadBalancerObject
    storageAccountSubscriptionId: storageAccountSubscriptionId
    storageAccountResourceGroup: 'rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-sec-stor-00${rg.rgInstance}'
    storageAccountName: 'sto${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }diagnlogs00${rg.StorageAccountInstance}'
    workspaceResourceGroup: 'rg-${environmentPrefix}-${(rg.workspaceLocation == 'australiaeast') ? 'edc' : 'sdc' }-sec-sec-00${rg.rgInstance}'
    workspaceSubscriptionId: workspaceSubscriptionId
    workspaceName: 'ws-${environmentPrefix}-${(rg.workspaceLocation == 'australiaeast') ? 'edc' : 'sdc' }-00${rg.rgInstance}'
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]
