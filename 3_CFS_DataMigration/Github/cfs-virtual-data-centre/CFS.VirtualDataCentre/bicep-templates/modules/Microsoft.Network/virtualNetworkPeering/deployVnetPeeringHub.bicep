param localVirtualNetworkName string
param remoteVirtualNetworkName string
param remoteVirtualNetworkResourceGroup string
param remoteVirtualNetworkSubscriptionId string

var remoteVnetResourceId = resourceId(remoteVirtualNetworkSubscriptionId, remoteVirtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks', remoteVirtualNetworkName)

//var remoteVnetResourceId = '/subscriptions/${remoteVirtualNetworkSubscriptionId}/resourceGroups/${remoteVirtualNetworkResourceGroup}/providers/Microsoft.Network/virtualNetworks/${remoteVirtualNetworkName}'

resource localVirtualNetworkName_peer_localVirtualNetworkName_to_remoteVirtualNetworkName 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-12-01' = {
  name: '${localVirtualNetworkName}/${localVirtualNetworkName}-to-${remoteVirtualNetworkName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: remoteVnetResourceId
    }
  }
}
