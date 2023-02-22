@description('The name of the existing network security group to create.')
param securityGroupName string

@description('The name of the virtual network to create.')
param spokeVnetName string

@description('The name of the private subnet to create.')
param privateSubnetName string = 'private-subnet'

@description('The name of the public subnet to create.')
param publicSubnetName string = 'public-subnet'

// @description('Name of the Routing Table')
// param routeTableName string

@description('Location for all resources.')
param vnetLocation string = resourceGroup().location

@description('Cidr range for the spoke vnet.')
param spokeVnetCidr string

@description('Cidr range for the private subnet.')
param privateSubnetCidr string

@description('Cidr range for the public subnet.')
param publicSubnetCidr string

param tags object

var securityGroupId = resourceId('Microsoft.Network/networkSecurityGroups', securityGroupName)

resource spokeVnetName_resource 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  location: vnetLocation
  name: spokeVnetName
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVnetCidr
      ]
    }
    subnets: [
      {
        name: publicSubnetName
        properties: {
          addressPrefix: publicSubnetCidr
          networkSecurityGroup: {
            id: securityGroupId
          }
          // routeTable: {
          //   id: resourceId('Microsoft.Network/routeTables', routeTableName)
          // }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                resourceGroup().location
              ]
            }
          ]          
        }
      }
      {
        name: privateSubnetName
        properties: {
          addressPrefix: privateSubnetCidr
          networkSecurityGroup: {
            id: securityGroupId
          }
          // routeTable: {
          //   id: resourceId('Microsoft.Network/routeTables', routeTableName)
          // }   
            serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                resourceGroup().location
              ]
            }
          ]     
        }
      }      
    ]
    enableDdosProtection: false
  }
}

// resource spokeVnetName_Peer_SpokeHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-08-01' = {
//   parent: spokeVnetName_resource
//   name: 'Peer-SpokeHub'
//   properties: {
//     allowVirtualNetworkAccess: true
//     allowForwardedTraffic: true
//     allowGatewayTransit: false
//     useRemoteGateways: false
//     remoteVirtualNetwork: {
//       id: hubVnetName_resource.id
//     }
//   }
// }

output spoke_vnet_id string = spokeVnetName_resource.id
output spoke_vnet_name string= spokeVnetName
output PublicSubId string = resourceId('Microsoft.Network/virtualNetworks/subnets', spokeVnetName, publicSubnetName)
