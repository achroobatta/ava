targetScope = 'subscription'

param localVirtualNetworkSubscriptionId string
param remoteVirtualNetworkSubscriptionId string
param vnetPeeringArray array

@batchSize(1)
module vnetPeering '../../modules/Microsoft.Network/virtualNetworkPeering/deployVnetPeeringHub.bicep' = [for (peering, i) in vnetPeeringArray: {
  scope: resourceGroup(peering.localVirtualNetworkResourceGroup)
  name: '${peering.localVirtualNetworkName}-${peering.remoteVirtualNetworkName}-${i}'
  params: {
    localVirtualNetworkName: peering.localVirtualNetworkName
    remoteVirtualNetworkName: peering.remoteVirtualNetworkName
    remoteVirtualNetworkResourceGroup: peering.remoteVirtualNetworkResourceGroup
    remoteVirtualNetworkSubscriptionId: remoteVirtualNetworkSubscriptionId
  }
}]

@batchSize(1)
module vnetPeering1 '../../modules/Microsoft.Network/virtualNetworkPeering/deployVnetPeeringtoHub.bicep' = [for (peering, i) in vnetPeeringArray: {
  scope: resourceGroup(peering.remoteVirtualNetworkResourceGroup)
  name: '${peering.remoteVirtualNetworkName}-${peering.localVirtualNetworkName}-${i}'
  params: {
    localVirtualNetworkName: peering.localVirtualNetworkName
    localVirtualNetworkResourceGroup: peering.localVirtualNetworkResourceGroup
    localVirtualNetworkSubscriptionId: localVirtualNetworkSubscriptionId
    remoteVirtualNetworkName: peering.remoteVirtualNetworkName
  }
}]
