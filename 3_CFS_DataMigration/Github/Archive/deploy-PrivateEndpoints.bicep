targetScope = 'subscription'

param virtualNetworkResourceGroup string
param environmentPrefix string
param serviceAbbrv string
param instance int
param location string
param privateDnsZoneName string
param virtualNetworkName string
param subnetName string

@description('Parameters for resource tags')
param appName string
param australiaEastOffsetSymbol string
param costCenter string
param owner string
param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')

var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: virtualNetworkResourceGroup
}

module privateDNSDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_adf.bicep' = {
  scope: resourceGroup(virtualNetworkResourceGroup)
  name:  'pridnsdeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}'
  params: {
    privateDnsZoneName: privateDnsZoneName
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    subnetName: subnetName
    location: location
    adfName: 'adfdeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 	
    appName: appName  	   
    costCenter: costCenter
    owner: owner 
    createOnDate: createOnDate
  }
  dependsOn: [
    rgDeploy
  ]
}
