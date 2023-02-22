param privateEndpointSubnet string
param variables_appServiceResourcesDeployment string
param variables_subnetAddressForApp string
param hostingPlanName string
param location string
param workerSize string
param workerSizeId string
param numberOfWorkers string
param sku string
param skuCode string
param name string
param linuxFxVersion string
param subscriptionId string
param serverFarmResourceGroup string
param isVnetEnabled bool
param vnetName string
param subnetForApp string
param isPrivateEndpointForAppEnabled bool
param privateEndpointNameForApp string
param privateDnsZoneNameForApp string

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  tags: {}
  properties: {
    name: hostingPlanName
    workerSize: workerSize
    workerSizeId: workerSizeId
    numberOfWorkers: numberOfWorkers
    reserved: true
  }
  sku: {
    tier: sku
    name: skuCode
  }
}

resource name_resource 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  tags: {}
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    name: name
    siteConfig: {
      http20Enabled: true
      minTlsVersion: '1.2'
      linuxFxVersion: linuxFxVersion
      acrUseManagedIdentityCreds: false
      appSettings: []
      vnetRouteAllEnabled: true
    }
    serverFarmId: '/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
    clientAffinityEnabled: false
    clientCertEnabled: true
    httpsOnly: true
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
  dependsOn: [
    hostingPlanName_resource
  ]
}

module variables_appServiceResourcesDeployment_vnet './nested_variables_appServiceResourcesDeployment_vnet.bicep' = if (isVnetEnabled) {
  name: '${variables_appServiceResourcesDeployment}-vnet'
  params: {
    vnetName: vnetName
    subnetForApp: subnetForApp
    variables_subnetAddressForApp: variables_subnetAddressForApp
    name: name
    isPrivateEndpointForAppEnabled: isPrivateEndpointForAppEnabled
    privateEndpointNameForApp: privateEndpointNameForApp
    location: location
    privateEndpointSubnet: privateEndpointSubnet
    privateDnsZoneNameForApp: privateDnsZoneNameForApp
  }
  dependsOn: [
    hostingPlanName_resource
    name_resource
  ]
}
