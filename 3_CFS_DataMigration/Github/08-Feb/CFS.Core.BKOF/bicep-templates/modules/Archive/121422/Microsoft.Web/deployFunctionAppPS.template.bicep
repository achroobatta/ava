@description('Azure datacentre Location to deploy Function App')
param funcAppResLocation string = resourceGroup().location

@description('Name of the Function App')
param functionAppName string

param funcappStgAccountName string

@description('Azure datacentre Location to deploy Function App')
param AppInsightsLocation string = resourceGroup().location

@description('Name of the Application Insight.')
param AppInsightsName string

//param appserviceplanID string

@description('Azure datacentre Location to deploy App Service Plan')
param appServicePlanLocation string = resourceGroup().location

@description('Name of the App Service Plan')
param appServicePlanName string

param tags object

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: funcappStgAccountName
  location: funcAppResLocation  
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_RAGRS'
  }
  properties:{
    allowBlobPublicAccess: false
    publicNetworkAccess:'Disabled'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  tags: tags
  location: appServicePlanLocation
  sku: {
    name: 'P1v2'
    /*
    tier: 'PremiumV2'
    size: 'P1v2'
    family: 'Pv2'
    capacity: 1
    */
  }
  kind: 'app'
  properties: {
    // perSiteScaling: false
    // elasticScaleEnabled: false
    // maximumElasticWorkerCount: 1
    // isSpot: false
    reserved: false
    // isXenon: false
    // hyperV: false
    // targetWorkerCount: 0
    // targetWorkerSizeId: 0
    // zoneRedundant: false
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: AppInsightsName
  tags: tags
  location: AppInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'IbizaWebAppExtensionCreate'
  }
}

resource functionAppName_resource 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  tags: tags
  location: funcAppResLocation
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcappStgAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
      ]
      ftpsState: 'FtpsOnly'
      powerShellVersion: '7.2'
      netFrameworkVersion: 'v6.0'
      minTlsVersion: '1.2'
      http20Enabled: true
      alwaysOn: true
    }
    httpsOnly: true
  }
}
