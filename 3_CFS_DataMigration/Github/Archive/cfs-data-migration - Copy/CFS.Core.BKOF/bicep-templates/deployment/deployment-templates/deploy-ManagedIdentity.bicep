targetScope = 'subscription'

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

param rgname string
param rgname2 string
param appName string
param environmentPrefix string
param component string
param serviceAbbrv string
param instance string 
param location string
param location2 string

module managedIdentityEDC '../../modules/Microsoft.ManagedIdentity/deployManagedIdentity.bicep' = {
  scope: resourceGroup(rgname)
  name: 'mideploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-${component}-00${instance}' 
  params: {
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    location: location
    maanagedIdentityName: 'mi-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-${component}-00${instance}' 
    owner: owner
  }
}

module managedIdentitySDC '../../modules/Microsoft.ManagedIdentity/deployManagedIdentity.bicep' = {
  scope: resourceGroup(rgname2)
  name: 'mideploy-${environmentPrefix}-${(location2 == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-${component}-00${instance}' 
  params: {
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    location: location2
    maanagedIdentityName: 'mi-${environmentPrefix}-${(location2 == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-${component}-00${instance}' 
    owner: owner
  }
}
