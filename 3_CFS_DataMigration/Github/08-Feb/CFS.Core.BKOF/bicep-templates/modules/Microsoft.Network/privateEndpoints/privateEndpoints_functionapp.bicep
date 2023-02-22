
param location string
param funcappName string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param privateDnsZoneName string
param funcappRG string

@description('Parameters for resource tags')
param createOnDate string
param owner string
param costCenter string
param appName string
param environmentPrefix string

var privateEndpointNameForFunctionApp = 'pve-${location}-${funcappName}'


resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource privateEndpointNameForFuncApp_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointNameForFunctionApp
  location: location
  tags: {
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environment: environmentPrefix
  }
  properties: {
    subnet: {
      id: '${virtualNetwork_resource.id}/subnets/${subnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointNameForFunctionApp
        properties: {
          //privateLinkServiceId: resourceId('Microsoft.Web/sites/', funcappName)
          //privateLinkServiceId: '/subscriptions/${subscriptionId}/resourceGroups/${funcappRG}/providers/Microsoft.Web/sites/${funcappName}'
          privateLinkServiceId: resourceId(funcappRG, 'Microsoft.Web/sites/', funcappName)
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateEndpointNameForFuncApp_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointNameForFunctionApp}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'funcapp-config'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', privateDnsZoneName)
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointNameForFuncApp_resource
  ]
}
