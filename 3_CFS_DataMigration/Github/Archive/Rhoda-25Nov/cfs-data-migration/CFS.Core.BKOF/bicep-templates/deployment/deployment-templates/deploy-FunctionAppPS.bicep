targetScope = 'subscription'

param environmentPrefix string
param resourceGroupObject object

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

@batchSize(1)
module functionappDeploy '../../modules/Microsoft.Web/deployFunctionAppPS.template.bicep' = [for rg in resourceGroupObject.resourceGroups:{
  scope: resourceGroup(rg.rgname)
  //scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  name: 'funcappdeploy-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}' 
  params: {
    AppInsightsName: 'appins-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}' 
    funcappStgAccountName: 'fsto${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }${rg.component}00${rg.instance}'  
    functionAppName: 'funcapp-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}' 
    appServicePlanName: 'appplan-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
    funcAppResLocation: rg.location
    AppInsightsLocation: rg.location
    appServicePlanLocation: rg.location
    tags: {
      appName: rg.appName
      environment: environmentPrefix
      owner: owner
      costCenter: costCenter
      createOnDate: createOnDate
    }
  }
}]

@batchSize(1)
module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateendpoints_storage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup(rg.rgname)
  name: 'pvedeploy-${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: rg.location
    storageName: 'fsto${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }${rg.component}00${rg.instance}'  
    subnetName: rg.subnetName
    virtualNetworkName: rg.virtualNetworkName
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    privateDnsZoneName: rg.storageprivateDnsZoneName
    appName: rg.appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
    component: rg.component
    instance: rg.instance
    locationAbbrv: rg.locationAbbrv
    serviceAbbrv: rg.serviceAbbrv
    stoprefix: rg.stoprefix
    storageRG: rg.storageRG
  }
  dependsOn: [
    functionappDeploy
  ]
}]

@batchSize(1)
module privateendpointforFunctionAppDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_functionapp.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup(rg.rgname)
  name: 'pvefadeploy-${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: rg.location
    funcappName: 'funcapp-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}' 
    subnetName: rg.subnetName
    virtualNetworkName: rg.virtualNetworkName
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    privateDnsZoneName: rg.funcappprivateDnsZoneName
    appName: rg.appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
    funcappRG: rg.funcappRG
  }
  dependsOn: [
    functionappDeploy
  ]
}]

@batchSize(1)
module privateendpointforstorage2Deploy '../../modules/Microsoft.Network/privateEndpoints/privateendpoints_storage.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup(rg.rgname2)
  name: 'pvedeploy-${environmentPrefix}${(rg.location2 == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: rg.location2
    storageName: 'fsto${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }${rg.component}00${rg.instance}'  
    subnetName: rg.subnet2Name
    virtualNetworkName: rg.virtualNetwork2Name
    virtualNetworkResourceGroup: rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.storageprivateDnsZoneName
    appName: rg.appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
    component: rg.component
    instance: rg.instance
    locationAbbrv: rg.locationAbbrv
    serviceAbbrv: rg.serviceAbbrv
    stoprefix: rg.stoprefix
    storageRG: rg.storageRG
  }
  dependsOn: [
    functionappDeploy
  ]
}]

@batchSize(1)
module privateendpointforFunctionApp2Deploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_functionapp.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  scope: resourceGroup(rg.rgname2)
  name: 'pvefadeploy-${environmentPrefix}${(rg.location2 == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  params: {
    location: rg.location2
    funcappName: 'funcapp-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc'}-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}' 
    subnetName: rg.subnet2Name
    virtualNetworkName: rg.virtualNetwork2Name
    virtualNetworkResourceGroup: rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.funcappprivateDnsZoneName
    appName: rg.appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
    funcappRG: rg.funcappRG
  }
  dependsOn: [
    functionappDeploy
  ]
}]
