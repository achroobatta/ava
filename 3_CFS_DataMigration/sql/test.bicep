var vnetId = '/subscriptions/a5b0380d-1f49-475e-b6a1-788228c2970b/resourceGroups/demorg/providers/Microsoft.Network/virtualNetworks/demovnet'
var subnetId = '${vnetId}/subnets/PrivateLinkSubnetCidr'


resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' = {
  name: 'demosql-ab'
  location: 'australiaeast'
  properties: {
    administratorLogin: 'demousr'
    administratorLoginPassword: 'Administrator@890'
    publicNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  parent: sqlServer
  name: 'demosqlab'
  location: 'australiaeast'
  sku: {
    name: 'Standard'
    tier: 'Standard'
    
  }
  // tags: {
  //     Costcenter: costCenter
  //     Servicerequest: serviceRequest
  //     Startdate: startDate
  //     Enddate: endDate
  // }  
}

var sqlId = '/subscriptions/a5b0380d-1f49-475e-b6a1-788228c2970b/resourceGroups/demorg/providers/Microsoft.Sql/servers/demosql-ab' 

resource sqlserverEP 'Microsoft.Network/privateEndpoints@2020-03-01' = {
  location: 'australiaeast'
  name: 'endpointName-sql'
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        type: 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections'
        name: 'endpointName'
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
  dependsOn: [
    sqlServer
  ]
}
