@description('Web app name.')
@minLength(2)
param webAppName string = 'webApp-${uniqueString(resourceGroup().id)}'

@description('Location for all resources.')
param ResouceGroupLocation string

@description('The SKU of App Service Plan.')
param sku string

@description('The Runtime stack of current web app')
param windowsFxVersion string

@description('Optional Git Repo URL')
param repoUrl string 

var appServicePlanPortalName_var = 'AppServicePlan-${webAppName}'

resource appServicePlanPortalName 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanPortalName_var
  location: ResouceGroupLocation
  sku: {
    name: sku
  }
  kind: 'windows'
  properties: {
    reserved: true
  }
}

resource webAppName_resource 'Microsoft.Web/sites@2021-02-01' = {
  name: webAppName
  location: ResouceGroupLocation
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlanPortalName.id
    clientCertEnabled: true
    siteConfig: {
      windowsFxVersion: windowsFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      http20Enabled: true
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource webAppName_web 'Microsoft.Web/sites/sourcecontrols@2021-02-01' = if (contains(repoUrl, 'http')) {
  parent: webAppName_resource
  name: 'web'
  properties: {
    repoUrl: repoUrl
    branch: 'master'
    isManualIntegration: true
  }
}
