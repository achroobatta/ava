param localVirtualNetworkName string
param localVirtualNetworkResourceGroup string
param localVirtualNetworkSubscriptionId string
param remoteVirtualNetworkName string

var localVnetResourceId = resourceId(localVirtualNetworkSubscriptionId, localVirtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks', localVirtualNetworkName)

//var localVnetResourceId = '/subscriptions/${localVirtualNetworkSubscriptionId}/resourceGroups/${localVirtualNetworkResourceGroup}/providers/Microsoft.Network/virtualNetworks/${localVirtualNetworkName}'

resource remoteVirtualNetworkName_peer_remoteVirtualNetworkName_to_localVirtualNetworkName 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-12-01' = {
  name: '${remoteVirtualNetworkName}/${remoteVirtualNetworkName}-to-${localVirtualNetworkName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: localVnetResourceId
    }
  }
}
