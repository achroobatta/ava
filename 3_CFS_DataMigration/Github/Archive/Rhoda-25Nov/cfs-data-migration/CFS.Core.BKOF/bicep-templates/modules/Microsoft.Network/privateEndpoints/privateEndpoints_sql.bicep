//param databaseName string
param location string
param sqlServerName string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param privateDnsZoneName string
// param subscriptionId string
param sqlRG string

@description('Parameters for resource tags')
param createOnDate string
param owner string
param costCenter string
param appName string
param environmentPrefix string

var privateEndpointNameForDb = 'pve-${location}-${sqlServerName}'


resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource privateEndpointNameForDb_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointNameForDb
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
        name: privateEndpointNameForDb
        properties: {
          privateLinkServiceId: resourceId(sqlRG, 'Microsoft.Sql/servers/', sqlServerName)
          //privateLinkServiceId: '/subscriptions/${subscriptionId}/resourceGroups/${sqlRG}/providers/Microsoft.Sql/servers/${sqlServerName}'
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
