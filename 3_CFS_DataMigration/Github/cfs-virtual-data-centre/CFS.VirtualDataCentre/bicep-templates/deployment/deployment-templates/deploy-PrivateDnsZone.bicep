targetScope = 'subscription'

@description('Private DNS Zone Object')
param privateDnsZoneObject object

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

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in privateDnsZoneObject.privateDnsZone: {
  name: 'rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.rgServiceAbbrv}-${rg.rgComponent}-00${rg.rgInstance}'
  location: rg.location
  tags: {
    appName: rg.appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }

}]

module privateDNSZone_resource '../../modules/Microsoft.Network/privateDnsZones/deploy-PrivateDnsZone.bicep' = [for rg in privateDnsZoneObject.privateDnsZone: {
  name: 'PrivateDNSZOne'
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.rgServiceAbbrv}-${rg.rgComponent}-00${rg.rgInstance}')
  params: {
    virtualNetworkLinks: rg.virtualNetworkLinks
    privateDnsZoneName: rg.privateDnsZoneName
    subscriptionId: subscriptionId
  }
}]
