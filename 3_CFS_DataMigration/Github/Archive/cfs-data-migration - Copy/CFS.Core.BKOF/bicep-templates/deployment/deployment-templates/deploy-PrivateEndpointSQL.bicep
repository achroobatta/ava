targetScope = 'subscription'

param environmentPrefix string

param appName string
param serviceAbbrv string
param instance string
param privateDnsZoneName string
param sqlServerName string
param sqlRG string
// param subscriptionId string
param rgname2 string
param location2 string
param subnet2Name string
param virtualNetwork2Name string
param virtualNetwork2ResourceGroup string
param component string

//param databaseName string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

//var contributorRoleDefId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

module privateendpointforstorage2Deploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_sql.bicep' = {
  scope: resourceGroup(rgname2)
  name: 'pekvdeploy2-${environmentPrefix}-${(location2 == 'australiaeast') ? 'edc' : 'sdc'}-${serviceAbbrv}-${component}-00${instance}' 
  params: {
    location: location2
    sqlServerName: sqlServerName
    //databaseName: databaseName
    subnetName: subnet2Name
    virtualNetworkName: virtualNetwork2Name
    virtualNetworkResourceGroup: virtualNetwork2ResourceGroup
    privateDnsZoneName: privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    sqlRG: sqlRG
    // subscriptionId: subscriptionId
  }
}
