targetScope = 'subscription'

@description('Parameter Array for App service module')
param appServiceArray array

@description('Parameters for Resource Group')
param rgArray array

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (rg, i) in rgArray: if (!empty(rg.AppServiceResourceGroupName)) {
  name: rg.AppServiceResourceGroupName
  location: rg.ResouceGroupLocation
}]

@batchSize(1)
module appService 'AppService.bicep' = [for (appService, i) in appServiceArray: if (!empty(appService.webAppName)){
  name: appService.webAppName
  scope: resourceGroup(appService.AppServiceResourceGroupName)
  params: {
    ResouceGroupLocation: appService.ResouceGroupLocation
    sku:appService.sku
    windowsFxVersion: appService.windowsFxVersion
    repoUrl:appService.repoUrl
  }
  dependsOn: [
    rg
  ]
}]
