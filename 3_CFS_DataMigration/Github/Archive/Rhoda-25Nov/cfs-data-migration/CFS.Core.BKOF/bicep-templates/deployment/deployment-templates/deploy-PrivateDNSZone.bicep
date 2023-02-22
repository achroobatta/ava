targetScope = 'subscription'

param resourceGroupObject object
param environmentPrefix string

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

@batchSize(1)
module privateDNSedcDeploy '../../modules/Microsoft.Network/privateDnsZones/deployPrivateDnsZone.bicep' = [for rg in resourceGroupObject.resourceGroups1: {
  scope: resourceGroup(rg.rgname)
  name:  'pdzdeploy-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-00${rg.instance}'
  params: {
    privateDnsZoneName: rg.privateDnsZoneName
    virtualNetworkName: rg.virtualNetworkName
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    appName: rg.appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
  }
}]

@batchSize(1)
module privateDNSsdcDeploy '../../modules/Microsoft.Network/privateDnsZones/deployPrivateDnsZone.bicep' = [for rg in resourceGroupObject.resourceGroups2: {
  scope: resourceGroup(rg.rgname)
  name:  'pdzdeploy-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-00${rg.instance}'
  params: {
    privateDnsZoneName: rg.privateDnsZoneName
    virtualNetworkName: rg.virtualNetworkName
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    appName: rg.appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
  }
}]
