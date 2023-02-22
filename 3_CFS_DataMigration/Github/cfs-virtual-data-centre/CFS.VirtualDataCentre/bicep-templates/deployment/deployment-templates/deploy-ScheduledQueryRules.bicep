// Params from the *.parameters.json file
param scheduledQueryRulesObject object
//param actionGroupRG string = 'rg-np-edc-oper-snow-001'
//param actionGroupSubscriptionId string = '7bc6726b-72bf-4265-a0f6-8b3f27959830'

//pipeline parameters
param location string
//param environmentType string
//param deployDate string

module scheduledQueryRulesModule '../../modules/Microsoft.Insights/scheduledQueryRules.module.bicep' = [for scheduledQueryRules in scheduledQueryRulesObject.scheduledQueryRules:{
  name: replace(scheduledQueryRules.name, ' ','-') //Replace spaces
  scope: resourceGroup()
  params: {
  //  actionGroupSubscriptionId: actionGroupSubscriptionId
  //  actionGroupRG: actionGroupRG
    scheduledQueryRulesObject: scheduledQueryRules
    location: location
    name: scheduledQueryRules.name
    dimensions: split(scheduledQueryRules.dimensionNames,',')
    //tags:{
    //  Environment: environmentType
    //  DeployDate: deployDate
    //  Owner: resourceGroup().tags['owner']
    //  CostCentre: resourceGroup().tags['costCenter']
    //  Application: resourceGroup().tags['appName']
    //}
  }
}]
