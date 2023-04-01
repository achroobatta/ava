targetScope = 'subscription'

param scalingPlanObject object
param environmentPfx string
param locationEdcPfx string


@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
@description('The string value for owner tag')
param owner string
@description('The string value for CostCenter tag')
param costCenter string
@description('The string value for appName tag')
param appName string
@description('Environment')
param environment string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('Location of resources')
param location string

// @batchSize(1)
module deploySp '../../modules/Microsoft.Avd/deployAvdScalingPlan.bicep' = [for (sp, i) in scalingPlanObject.scalingPlanValues:{
  scope: resourceGroup(sp.spRgName)
  name: 'deploy-AVD-SP-${locationEdcPfx}-00${sp.spInstance}'
  params: {
    spName: 'sp-${environmentPfx}-avd-sd-00${sp.spInstance}'
    location: location
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    environment: environment
    owner: owner
    spDescription: sp.description
    spExclusionTag: sp.exclusionTag
    spFriendlyName: sp.friendlyName
    timeZone: sp.timeZone
    hpPoolType: sp.hpPooledType
    hpNamesforAssignment: sp.hpNamesforAssignment
    schedulingObj: sp.schedulingObject
  }
}]
