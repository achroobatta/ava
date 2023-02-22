@description('Virtual Network Name')
param virtualNetworkName string

@description('Virtual Network Resource Group')
param virtualNetworkResourceGroup string

@description('Private DNS Zone Name for Database')
param privateDnsZoneName string

@description('Parameters for resource tags')
param appName string
param owner string
param costCenter string
param createOnDate string
param environmentPrefix string

resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource privateDnsZoneName_resource 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: {
    appName: appName    
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    environment: environmentPrefix
  }
}

resource privateDnsZoneName_vnetlink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${privateDnsZoneName}/${privateDnsZoneName}-vnetlink'
  location: 'global'
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    virtualNetwork: {
      id: virtualNetwork_resource.id
    }
    registrationEnabled: false
  }
  dependsOn: [
    privateDnsZoneName_resource
  ]
}
