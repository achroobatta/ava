param location string
param kvName string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param privateDnsZoneName string
// param subscriptionId string
param kvRG string

@description('Parameters for resource tags')
param createOnDate string
param owner string
param costCenter string
param appName string
param environmentPrefix string

var privateEndpointNameForKv = 'pve-${location}-${kvName}'


resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource privateEndpointNameForKv_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointNameForKv
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
        name: privateEndpointNameForKv
        properties: {
          privateLinkServiceId: resourceId(kvRG, 'Microsoft.KeyVault/vaults', kvName)
          //privateLinkServiceId: '/subscriptions/${subscriptionId}/resourceGroups/${kvRG}/providers/Microsoft.KeyVault/vaults/${kvName}'
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource privateEndpointNameForKv_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointNameForKv}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'keyvault-config'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', privateDnsZoneName)
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointNameForKv_resource
  ]
}
