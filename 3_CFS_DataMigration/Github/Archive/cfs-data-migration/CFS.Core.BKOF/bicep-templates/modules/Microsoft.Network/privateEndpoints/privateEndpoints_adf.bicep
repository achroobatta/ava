param location string
param adfName string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param privateDnsZoneName string
param adfresourceID string

@description('Parameters for resource tags')
param createOnDate string
param owner string
param costCenter string
param appName string
param environmentPrefix string

var privateEndpointNameForAdf = 'pve-${location}-${adfName}'

resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource privateEndpointNameForAdf_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointNameForAdf
  location: location
  tags: {
    appName: appName
    costCenter: costCenter
    owner: owner
    createOnDate: createOnDate
    environment: environmentPrefix
  }
  properties: {
    subnet: {
      id: '${virtualNetwork_resource.id}/subnets/${subnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointNameForAdf
        properties: {
          privateLinkServiceId: adfresourceID
          groupIds: [
            'dataFactory'
          ]
        }
      }
    ]
  }
}

resource privateEndpointNameForAdf_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointNameForAdf}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'adf-config'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', privateDnsZoneName)
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointNameForAdf_resource
  ]
}
