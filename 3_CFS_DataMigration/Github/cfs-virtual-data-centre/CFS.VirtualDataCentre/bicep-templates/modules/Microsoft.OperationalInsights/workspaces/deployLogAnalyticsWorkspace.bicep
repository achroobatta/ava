@description('Name of the workspace that will be deployed')
param workspaceName string

@description('Input the desired service tier for the pricing and features to be included - Free, Standalone, PerNode or PerGB2018')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param serviceTier string = 'PerGB2018'

@description('The number of days to keep the logs in the log analytics workspace')
@minValue(0)
@maxValue(365)
param dataRetention int = 365

@description('Provide the Azure regiond where to deploy the log analytics workspace')
param location string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

resource workspaceName_resource 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  location: location
  name: workspaceName
  properties: {
    sku: {
      name: serviceTier
    }
    retentionInDays: dataRetention
  }
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}
