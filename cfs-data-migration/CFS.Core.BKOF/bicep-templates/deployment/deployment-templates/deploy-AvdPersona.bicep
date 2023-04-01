targetScope = 'subscription'

@description('Parameter Object for Avd module from Persona Parameter Json')
param locationEdcPfx string
param locationSdcPfx string
param environmentPfx string
param avdLocation string
param avdRdpProperties string

@description('Parameter Object for Avd module from Persona Parameter Json')
param personaObject object

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
@description('The string value for owner tag')
param owner string
@description('The string value for CostCenter tag')
param costCenter string
@description('The string value for appName tag')
param appName string
@description('Prefix for Project for which we need to create Avd')
param projectPfx string
@description('Location of resources')
param location string
@description('Environment')
param environment string

param logAnalyticsWorkspaceSubId string

var upperProjectPfx = toUpper(projectPfx)
var locationName = (location == 'australiaeast') ? 'Sydney' : 'Melbourne'


resource rgName 'Microsoft.Resources/resourceGroups@2022-09-01' existing =[for (pa, i) in personaObject.personaValues: {
 name: 'rg-${environmentPfx}-${(location == 'australiaeast') ? locationEdcPfx : locationSdcPfx}-${pa.rgServicePfx}-${pa.rgServiceAbbrevPfx}-00${pa.rgInstance}'
}]

@batchSize(1)
module deployAvd '../../modules/Microsoft.Avd/deployAvdPersona.bicep' = [for (pa, i) in personaObject.personaValues: {
  name: 'deploy-AVD-${(location == 'australiaeast') ? locationEdcPfx: locationSdcPfx}-00${pa.rgInstance}'
  scope: rgName[i]
  params: {
      appName: appName
      environment: environment
      owner: owner
      costCenter: costCenter
      createOnDate: createOnDate
      hpAppGroupType: pa.hpAppGroupType
      hpDescription: pa.hpdDescription
      hpDesktopAssignmentType: pa.hpDesktopAssignmentType
      hpHostPoolType: pa.hpHostPooledType
      hpLoadBalancerType: pa.hpLoadBalancerType
      location: avdLocation //Host Pool is not available in australiasoutheast, so deploying in australieast
      hpMaxSessionLimit: pa.hpMaxSessionLimit
      hpName: 'hp-${environmentPfx}-${(location == 'australiaeast') ? locationEdcPfx : locationSdcPfx}-${projectPfx}-avd-${pa.avdServiceAbbrevPfx}-00${pa.hpInstance}'
      agDescription: pa.agDescription
      agFriendlyName: pa.agFriendlyName
      agAppGroupType: pa.hpAppGroupType
      wsDescription: pa.wsDescription
      wsFriendlyName: pa.wsFriendlyName
      wsName: (environmentPfx == 'np') ? '${upperProjectPfx}-${locationName}-${pa.hpHostPooledType}-DEV' : '${upperProjectPfx}-${locationName}-${pa.hpHostPooledType}'
      logAnalyticsWorkspaceNm:'ws-${environmentPfx}-${locationEdcPfx}-001'
      logAnalyticsWorkspaceRg:'rg-${environmentPfx}-${locationEdcPfx}-sec-sec-001'
      logAnalyticsWorkspaceSubId: logAnalyticsWorkspaceSubId
      rdpProperties: avdRdpProperties
    }
  }]
