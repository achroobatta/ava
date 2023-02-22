param variables_vnetAddress string
param variables_subnetAddressForPrivateEndpoint string
param location string
param vnetName string
param privateEndpointSubnet string
param isPrivateEndpointForAppEnabled bool
param privateDnsZoneNameForApp string
param privateDnsZoneNameForDb string

resource vnetName_resource 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  location: location
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: [
        variables_vnetAddress
      ]
    }
    subnets: []
  }
}

resource vnetName_privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${vnetName}/${privateEndpointSubnet}'
  properties: {
    delegations: []
    serviceEndpoints: []
    addressPrefix: variables_subnetAddressForPrivateEndpoint
    privateEndpointNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    vnetName_resource
  ]
}

resource privateDnsZoneNameForApp_resource 'Microsoft.Network/privateDnsZones@2020-06-01' = if (isPrivateEndpointForAppEnabled) {
  name: privateDnsZoneNameForApp
  location: 'global'
}

resource privateDnsZoneNameForApp_privateDnsZoneNameForApp_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (isPrivateEndpointForAppEnabled) {
  name: '${privateDnsZoneNameForApp}/${privateDnsZoneNameForApp}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetName_resource.id
    }
    registrationEnabled: false
  }
  dependsOn: [
    privateDnsZoneNameForApp_resource
  ]
}

resource privateDnsZoneNameForDb_resource 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneNameForDb
  location: 'global'
}

resource privateDnsZoneNameForDb_privateDnsZoneNameForDb_vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZoneNameForDb}/${privateDnsZoneNameForDb}-vnetlink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetName_resource.id
    }
    registrationEnabled: false
  }
  dependsOn: [
    privateDnsZoneNameForDb_resource
  ]
}
