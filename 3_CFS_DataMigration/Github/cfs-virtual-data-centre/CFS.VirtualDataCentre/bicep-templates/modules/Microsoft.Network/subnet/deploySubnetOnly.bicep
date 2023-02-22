param vNetName string
param subnetName string
param subnetAddressPrefix string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${vNetName}/${subnetName}'
  properties: {
    addressPrefix: subnetAddressPrefix
  }
}
