targetScope = 'subscription'

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

param appName string
param rgname string
param location string
param serviceAbbrv string
param instance string
param privateDnsZoneName string
param subnetName string
param virtualNetworkName string
param virtualNetworkResourceGroup string

param rgname2 string
param location2 string
param subnet2Name string     
param virtualNetwork2Name string
param virtualNetwork2ResourceGroup string

module adfDeploy '../../modules/Microsoft.ADF/deployADF.bicep' = {
  scope: resourceGroup(rgname)
  name: 'adfdeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
  params: {
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    dataFactoryName: 'adf-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
    environmentPrefix: environmentPrefix
    location: location
    owner: owner
  }
}

module privateendpointADFDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_adf.bicep' = {
  scope: resourceGroup(rgname)
  name: 'pveadfdeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
  params: {
    adfName: 'adf-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
    adfresourceID: adfDeploy.outputs.adfresourceID
    location: location
    privateDnsZoneName: privateDnsZoneName
    subnetName: subnetName
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
  }
}

module privateendpoint2ADFDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_adf.bicep' = {
  scope: resourceGroup(rgname2)
  name: 'pveadfdeploy-${environmentPrefix}-${(location2 == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
  params: {
    adfName: 'adf-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
    adfresourceID: adfDeploy.outputs.adfresourceID
    location: location2
    privateDnsZoneName: privateDnsZoneName
    subnetName: subnet2Name
    virtualNetworkName: virtualNetwork2Name
    virtualNetworkResourceGroup: virtualNetwork2ResourceGroup
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
  }
}
