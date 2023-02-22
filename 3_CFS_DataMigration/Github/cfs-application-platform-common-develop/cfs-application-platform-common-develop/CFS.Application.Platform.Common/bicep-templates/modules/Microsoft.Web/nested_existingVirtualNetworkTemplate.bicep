param virtualNetworkName string
param subnetName string
param subnetAddress string
param delegationName string

resource virtualNetworkName_subnetName 'Microsoft.Network/virtualNetworks/subnets@2018-04-01' = {
  name: '${virtualNetworkName}/${subnetName}'
  properties: {
    addressPrefix: subnetAddress
    delegations: [
      {
        name: delegationName
        properties: {
          serviceName: 'Microsoft.Web/hostingEnvironments'
        }
      }
    ]
  }
}
