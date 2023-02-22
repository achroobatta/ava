resource sqlserver 'Microsoft.Network/privateEndpoints@2020-03-01' = if (targetResourceType == 'SQL Server') {
  location: location
  name: '${endpointName}-sql'
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        type: 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections'
        name: endpointName
        properties: {
          privateLinkServiceId: sqlId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
  tags: {
  }
}
