targetScope = 'subscription'

param remoteVirtualNetworkSubscriptionId string
param vnetPeeringArray array

@batchSize(1)
module vnetPeering1 '../../modules/Microsoft.Network/virtualNetworkPeering/deployVnetPeeringtoSpoke.bicep' = [for (peering, i) in vnetPeeringArray: {
  scope: resourceGroup(peering.localVirtualNetworkResourceGroup)
  name: 'vnetPeering-${peering.localVirtualNetworkName}-${peering.remoteVirtualNetworkName}-${i}'
  params: {
    localVirtualNetworkName: peering.localVirtualNetworkName
    remoteVirtualNetworkName: peering.remoteVirtualNetworkName
    remoteVirtualNetworkResourceGroup: peering.remoteVirtualNetworkResourceGroup
    remoteVirtualNetworkSubscriptionId: remoteVirtualNetworkSubscriptionId
  }
}]
