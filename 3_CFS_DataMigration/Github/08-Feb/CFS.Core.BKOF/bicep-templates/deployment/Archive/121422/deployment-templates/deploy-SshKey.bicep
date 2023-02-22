targetScope = 'subscription'

param environmentPrefix string
param resourceGroupObject object

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

@description('The string value for CostCenter tag')
param keyName string

var uniqueSubString = uniqueString(guid(subscription().subscriptionId))
var uString = '${keyName}${uniqueSubString}'


@batchSize(1)
module Sshkey '../../modules/Microsoft.Keys/generateSshKey.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'key${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  scope: resourceGroup(rg.rgname)
  params: {
    location: rg.location
    keyName: substring(uString, 0, 8)
    publicKeyName: 'pub${substring(uString, 0, 8)}'
    tags: {
      appName: rg.appName
      environmentPrefix: environmentPrefix
      owner: owner
      costCenter: costCenter
      createOnDate: createOnDate
    }
  }
}]
