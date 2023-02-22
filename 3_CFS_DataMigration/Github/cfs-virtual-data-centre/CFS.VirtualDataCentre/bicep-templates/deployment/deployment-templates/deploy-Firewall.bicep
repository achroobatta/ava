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

var hubVnet = [
  'hub'
]

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
module deployFirewallModule '../../modules/Microsoft.Network/azureFirewall/deployAzureFirewall.bicep' = [for vnet in virtualNetworkObject.virtualNetwork : if (contains(hubVnet, vnet.serviceAbbrv)) {
  name: 'deploy-fw-${environmentPrefix}-${(vnet.location == 'australiaeast') ? 'edc' : 'sdc' }-${vnet.serviceAbbrv}-${vnet.component}-00${vnet.instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(vnet.location == 'australiaeast') ? 'edc' : 'sdc' }-${vnet.serviceAbbrv}-${vnet.component}-00${vnet.instance}')
  params: {
    location: vnet.location
    rgName: 'rg-${environmentPrefix}-${(vnet.location == 'australiaeast') ? 'edc' : 'sdc' }-${vnet.serviceAbbrv}-${vnet.component}-00${vnet.instance}'
    vnetName: 'vnet-${environmentPrefix}-${(vnet.location == 'australiaeast') ? 'edc' : 'sdc' }-${(vnet.service == 'connectivity') ? 'hub' : vnet.service}-00${vnet.instance}'
    azureFirewallName: 'fw-${environmentPrefix}-${(vnet.location == 'australiaeast') ? 'edc' : 'sdc' }-${vnet.serviceAbbrv}-00${vnet.instance}'
    azureFirewallTier: vnet.firewallTierSKU
    isFirewallAZenable: vnet.isFirewallAZenable
    firewallPolicyname: 'fwp-${environmentPrefix}-${(vnet.location == 'australiaeast') ? 'edc' : 'sdc' }-${vnet.serviceAbbrv}-00${vnet.fwpinstance}'
    isForceTunnelingEnabled: vnet.isForceTunnelingEnabled
    storageAccountSubscriptionId: storageAccountSubscriptionId
    storageAccountResourceGroup: 'rg-${environmentPrefix}-${(vnet.location == 'australiaeast') ? 'edc' : 'sdc' }-sec-stor-00${vnet.instance}'
    storageAccountName: 'sto${environmentPrefix}${(vnet.location == 'australiaeast') ? 'edc' : 'sdc' }diagnlogs00${vnet.StorageAccountInstance}'
    workspaceSubscriptionId: workspaceSubscriptionId
    workspaceResourceGroup: 'rg-${environmentPrefix}-${(vnet.workspaceLocation == 'australiaeast') ? 'edc' : 'sdc' }-sec-sec-00${vnet.instance}'
    workspaceName: 'ws-${environmentPrefix}-${(vnet.workspaceLocation == 'australiaeast') ? 'edc' : 'sdc' }-00${vnet.instance}'
    appName: vnet.appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]
