param privateEndpointNameForDb string
param location string
param resourceId_Microsoft_Network_virtualNetworks_subnets_parameters_vnetName_parameters_privateEndpointSubnet string
param resourceId_Microsoft_Sql_servers_parameters_serverName string
param resourceId_Microsoft_Network_privateDnsZones_parameters_privateDnsZoneNameForDb string

resource privateEndpointNameForDb_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointNameForDb
  location: location
  properties: {
    subnet: {
      id: resourceId_Microsoft_Network_virtualNetworks_subnets_parameters_vnetName_parameters_privateEndpointSubnet
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointNameForDb
        properties: {
          privateLinkServiceId: resourceId_Microsoft_Sql_servers_parameters_serverName
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
          privateDnsZoneId: resourceId_Microsoft_Network_privateDnsZones_parameters_privateDnsZoneNameForDb
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointNameForDb_resource
  ]
}
