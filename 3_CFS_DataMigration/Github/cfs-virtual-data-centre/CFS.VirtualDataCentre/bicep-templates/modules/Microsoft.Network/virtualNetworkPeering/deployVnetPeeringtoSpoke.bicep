param localVirtualNetworkName string
param remoteVirtualNetworkResourceGroup string
param remoteVirtualNetworkSubscriptionId string
param remoteVirtualNetworkName string

var remoteVnetResourceId = '/subscriptions/${remoteVirtualNetworkSubscriptionId}/resourceGroups/${remoteVirtualNetworkResourceGroup}/providers/Microsoft.Network/virtualNetworks/${remoteVirtualNetworkName}'

resource localVirtualNetworkName_peer_localVirtualNetworkName_to_remoteVirtualNetworkName 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-12-01' = {
  name: '${localVirtualNetworkName}/${localVirtualNetworkName}-to-${remoteVirtualNetworkName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: remoteVnetResourceId
    }
  }
}
