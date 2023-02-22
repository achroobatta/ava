
param databaseName string
param location string
param sqlServerName string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param privateDnsZoneName string

var privateEndpointNameForDb = 'pve-${databaseName}'


resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource privateEndpointNameForDb_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointNameForDb
  location: location
  properties: {
    subnet: {
      id: '${virtualNetwork_resource.id}/subnets/${subnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointNameForDb
        properties: {
          privateLinkServiceId: resourceId('Microsoft.Sql/servers/', sqlServerName)
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource privateEndpointNameForDb_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointNameForDb}/default'
  location: location
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'database-config'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', privateDnsZoneName)
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointNameForDb_resource
  ]
}
