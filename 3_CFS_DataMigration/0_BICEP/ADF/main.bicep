targetScope = 'subscription'

@minLength(2)
@maxLength(4)
@description('2-4 chars to prefix the Azure resources, NOTE: no number or symbols')
param prefix string = 'cfs'
@description('Default location of the resources')
param location string = 'australiaeast'
@description('name of DM spoke vnet')
param spokeVnetName string = '${prefix}Vnet'
@description('vnet CIDR')
param SpokeVnetCidr string = '10.179.0.0/16'
@description('Private Subnet Range')
param PrivateSubnetCidr string = '10.179.0.0/18'
@description('Public Subnet Range')
param PublicSubnetCidr string = '10.179.64.0/18'
@description('username for vm')
param adminUsername string
@secure()
param adminPassword string

@description('tags variables')
param costCenter string = 'CFS'
param project string = 'ProjectCFS'

// Variable declaration
var uniqueSubString = uniqueString(guid(subscription().subscriptionId))
var uString = '${prefix}${uniqueSubString}'
var resourceGroupName = '${substring(uString, 0, 6)}rg'
var managedIdentityName = '${substring(uString, 0, 6)}Identity'
var shirPcName = '${substring(uString, 0, 6)}ShirPc'
var shirAdfIr= '${substring(uString, 0, 6)}ShirIR'
// achroo subscription
var subscriptionId = 'a5b0380d-1f49-475e-b6a1-788228c2970b'
//https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var ownerId = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var cfsAdf = '${substring(uString, 0, 6)}Adf'
var nsgName = '${substring(uString, 0, 6)}nsg'
var storageAccountName = '${substring(uString, 0, 10)}stg01'
// var subscriptionId = '980b624f-c0c5-4337-805c-c1b268ac0aa1'
var tags = {
   costCenter: costCenter
   project: project
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags 
}

module myIdentity './other/managedIdentity.template.bicep' = {
  scope: rg
  name: 'ManagedIdentity'
  params: {
    managedIdentityName: managedIdentityName
    location: location
    ownerRoleDefId: ownerId
    tags: tags 
  }
}

// module routeTable './network/routetable.template.bicep' = {
//   scope: rg
//   name: 'RouteTable'
//   params: {
//     routeTableName: fwRoutingTable
//   }
// }

module nsg './network/securitygroup.template.bicep' = {
  scope: rg
  name: 'NetworkSecurityGroup'
  params: {
    securityGroupName: nsgName
    securityGroupLocation: location
    tags: tags
  }
}

module vnets './network/vnet.template.bicep' = {
  scope: rg
  name: 'vnets'
  params: {    
    spokeVnetName: spokeVnetName
    securityGroupName: nsg.outputs.nsgName   
    // routeTableName: routeTable.outputs.routeTblName
    spokeVnetCidr: SpokeVnetCidr
    privateSubnetCidr: PrivateSubnetCidr  
    publicSubnetCidr: PublicSubnetCidr  
    tags: tags        
  }
}

// module adf './adf/adf.template.bicep' = {
//   scope: rg
//   name:  'cfsAdf'
//   params: {    
//      adfLocation: location
//      identity: myIdentity.outputs.mIdentityId  
//      cfsname: cfsAdf 
//      tags: tags
//   }
// }

// module shir './adf/shir.template.bicep' = {
//   scope: rg
//   name: 'cfsshir'
//   params: {
//     parentname: adf.outputs.adfid
//     shirname: shirAdfIr 
//   }
// }

// module adlsGen2 './storage/storageaccount.template.bicep' = {
//   scope: rg
//   name: 'StorageAccount'

//   params: {
//     storageAccountName: storageAccountName
//     identity: myIdentity.outputs.mIdentityId
//     PublicSubnetId: vnets.outputs.PublicSubId    
//   }
// }

//spin vm for shir
module shirpc './shirpc/vm.template.bicep' = {
  name: 'shirPC'
  scope: rg
  params: {
    // adminUsername: adminUsername
    // adminPassword: adminPassword
    vnetName: vnets.outputs.spoke_vnet_name
    shirPcName: shirPcName
    subscriptionId: subscriptionId
    identity: myIdentity.outputs.mIdentityId
    tags: tags
  }
  dependsOn: [
    vnets
  ]
}

//Connect vm with shir agent using shir keys 
// module vm_customScriptExtension 'shirpc/extension.template.bicep' = {
//   name: '${uniqueString(deployment().name, location)}-customScriptExt'
//   scope: rg 
//   params: {       
//        shirAdfIr: shirAdfIr
//        shirAdf: cfsAdf
//        shirPcName: shirpc.outputs.shirPCName
//        storageAccountName: storageAccountName
//        location: location
//        identity: myIdentity.outputs.mIdentityClientId
//        tags: tags 
//   }
//   // dependsOn: [
//   //   adlsGen2
//   // ]
// }

module run_command 'other/runCommand.bicep' = {
  name:  'runPowerShellCommand'
  scope: rg
  params: {
    location: location
    vmName: shirpc.outputs.shirPCName
  }
}
