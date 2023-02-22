param storageName string
param location string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param privateDnsZoneName string
// param subscriptionId string
param storageRG string

param privateEndpointNameForStorage string
@description('Parameters for resource tags')
param createOnDate string
param owner string
param costCenter string
param appName string
param environmentPrefix string

resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource privateEndpointNameForStorage_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointNameForStorage
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
        name: privateEndpointNameForStorage
        properties: {                 
          privateLinkServiceId: resourceId(storageRG,'Microsoft.Storage/storageAccounts/', storageName)
          // '/subscriptions/${subscriptionId}/resourceGroups/${storageRG}/providers/Microsoft.Storage/storageAccounts/${storageName}'
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource privateEndpointNameForStorage_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointNameForStorage}/default'  
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'storage-config'
        properties: {
          privateDnsZoneId: resourceId(virtualNetworkResourceGroup,'Microsoft.Network/privateDnsZones', privateDnsZoneName)
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointNameForStorage_resource
  ]
}
