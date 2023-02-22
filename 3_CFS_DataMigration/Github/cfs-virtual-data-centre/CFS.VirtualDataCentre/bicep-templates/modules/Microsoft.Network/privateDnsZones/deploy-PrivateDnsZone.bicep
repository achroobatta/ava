param virtualNetworkLinks array
param subscriptionId string

@description('Private DNS Zone Name for Database')
param privateDnsZoneName string

resource privateDnsZoneName_resource 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZoneName_vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (rg,i) in virtualNetworkLinks: {
  name: '${privateDnsZoneName}/${rg.linkName}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: resourceId(subscriptionId, rg.vnetResourceGroup, 'Microsoft.Network/virtualNetworks', rg.vnetName)
    }
    registrationEnabled: rg.isRegistrationEnabled
  }
  dependsOn: [
    privateDnsZoneName_resource
  ]
}]
