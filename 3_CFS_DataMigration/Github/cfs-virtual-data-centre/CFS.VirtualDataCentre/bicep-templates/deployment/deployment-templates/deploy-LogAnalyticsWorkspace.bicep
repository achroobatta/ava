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


resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
  location: rg.location
  tags: {
    appName: rg.appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

module lawdeploy '../../modules/Microsoft.OperationalInsights/workspaces/deployLogAnalyticsWorkspace.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'ws-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-00${rg.instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  params: {
    workspaceName: 'ws-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-00${rg.instance}'
    location: rg.location
    appName: rg.appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    }
    dependsOn: [
      rgDeploy
    ]
}]
