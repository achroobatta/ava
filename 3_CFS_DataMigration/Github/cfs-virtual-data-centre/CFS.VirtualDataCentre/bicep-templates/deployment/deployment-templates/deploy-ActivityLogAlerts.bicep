// Params from the *.param.<environmentPrefix>.json file
param activityLogAlertsObject object

param environmentPrefix string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for costCenter tag')
param costCenter string

@description('The string value for appName tag')
param appName string

module activityLogAlertsModule '../../modules/Microsoft.Insights/activityLogAlerts.module.bicep' = [for activityLogAlerts in activityLogAlertsObject.activityLogAlerts:{
  name: replace(activityLogAlerts.name, ' ','-') //Replace spaces
  scope: resourceGroup()
  params: {
    actionGroupName: activityLogAlertsObject.actionGroupName
    scopes: activityLogAlertsObject.scopes
    activityLogAlertsObject: activityLogAlerts
    location: 'global'                  // Must be global
    name: activityLogAlerts.name
    tags:{
      environment: environmentPrefix
      createOnDate: createOnDate
      owner: owner
      costCenter: costCenter
      appName: appName
    }
  }
}]
