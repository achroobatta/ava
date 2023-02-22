param vNetName string
param subnetName string
param subnetAddressPrefix string
param nsgName string
param serviceEndPoints array = []

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${vNetName}/${subnetName}'
  properties: {
    addressPrefix: subnetAddressPrefix
    serviceEndpoints: serviceEndPoints
    networkSecurityGroup: {
      id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
    }
  }
}
