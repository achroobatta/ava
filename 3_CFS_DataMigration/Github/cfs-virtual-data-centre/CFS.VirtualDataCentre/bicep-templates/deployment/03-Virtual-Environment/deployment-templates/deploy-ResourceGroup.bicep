targetScope = 'subscription'

param rgArray array
param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
@description('The string value for owner tag')
param owner string
@description('The string value for CostCenter tag')
param costCenter string
@description('Environment')
param environmentPrefix string
@description('Application Name')
param appName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (rg, i) in rgArray: {
  name: rg.name
  location: rg.vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]
