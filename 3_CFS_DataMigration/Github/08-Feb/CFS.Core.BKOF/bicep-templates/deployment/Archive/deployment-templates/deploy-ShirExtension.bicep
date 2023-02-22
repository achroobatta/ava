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

param rgname string
param dataFactoryName string
param location string
param vmResouceGroupLocation string
param shirVmName string
param appName string
param serviceAbbrv string
param instance string
param timeZone string
param identityClientID string
param adminUsername string

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: rgname
}

module vm_customScriptExtension '../../modules/Microsoft.Compute/deployShirExtension.bicep' = {
  scope: rgDeploy
  name: 'vmextdeploy-${environmentPrefix}-${(location == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-00${instance}' 
  params: {
    adminUsername: adminUsername
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    dataFactoryName: dataFactoryName
    environmentPrefix: environmentPrefix
    identity: identityClientID
    owner: owner
    shirVmName: shirVmName
    timeZone: timeZone
    vmResouceGroupLocation: vmResouceGroupLocation
  }
}
  
