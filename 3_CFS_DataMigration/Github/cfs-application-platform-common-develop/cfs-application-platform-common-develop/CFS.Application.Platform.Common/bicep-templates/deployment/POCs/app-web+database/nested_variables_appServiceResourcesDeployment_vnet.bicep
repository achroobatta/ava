param vnetName string
param subnetForApp string
param variables_subnetAddressForApp string
param name string
param isPrivateEndpointForAppEnabled bool
param privateEndpointNameForApp string
param location string
param privateEndpointSubnet string
param privateDnsZoneNameForApp string

resource vnetName_subnetForApp 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${vnetName}/${subnetForApp}'
  properties: {
    delegations: [
      {
        name: 'dlg-appServices'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
      }
    ]
    serviceEndpoints: []
    addressPrefix: variables_subnetAddressForApp
  }
}

resource name_virtualNetwork 'Microsoft.Web/sites/networkConfig@2021-03-01' = {
  name: '${name}/virtualNetwork'
  properties: {
    subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetForApp)
  }
  dependsOn: [
    vnetName_subnetForApp
  ]
}

resource privateEndpointNameForApp_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = if (isPrivateEndpointForAppEnabled) {
  name: privateEndpointNameForApp
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnet)
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointNameForApp
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Web/Sites', name)
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateEndpointNameForApp_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (isPrivateEndpointForAppEnabled) {
  name: '${privateEndpointNameForApp}/default'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneNameForApp
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', privateDnsZoneNameForApp)
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointNameForApp_resource
  ]
}
