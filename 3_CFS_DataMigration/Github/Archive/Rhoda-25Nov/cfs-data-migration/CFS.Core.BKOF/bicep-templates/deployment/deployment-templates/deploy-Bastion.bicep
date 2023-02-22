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
param location string
param serviceAbbrv string
param instance string
param bastionsubnetipprefix string

module BastionDeploy '../../modules/Microsoft.Network/bastionHosts/deployBastion.bicep' = {
  scope: resourceGroup('rg-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc' }-${serviceAbbrv}-00${instance}')
  name: 'bastiondeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
  params: {
    bastion_host_name: 'bastion-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc' }-${serviceAbbrv}-00${instance}'
    bastion_subnet_ip_prefix: bastionsubnetipprefix
    location: location
    resourceTags: {
      appName: appName
      environmentPrefix: environmentPrefix
      owner: owner
      costCenter: costCenter
      createOnDate: createOnDate
    }
    vnet_name: 'vnet-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc' }-${serviceAbbrv}-00${instance}'
  }
}
