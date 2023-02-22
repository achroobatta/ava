targetScope = 'subscription'

@description('Administrator password for the virtual machine')
@secure()
param adminPassword string

@description('Parameter Array for virtual machine module')
param vmArray array

@description('Parameters for Resource Group')
param rgArray array

@description('Parameter object for Resource Tags')
param resourceTags object

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (rg, i) in rgArray: if (!empty(rg.vmResourceGroupName)) {
  name: rg.vmResourceGroupName
  location: rg.vmResouceGroupLocation
}]

@batchSize(1)
module deployVM 'sqlVM.bicep' = [for (virtualmachine, i) in vmArray: if (!empty(virtualmachine.vmName)){
  name: virtualmachine.vmName
  scope: resourceGroup(virtualmachine.vmResourceGroupName)
  params: {
    vmName: virtualmachine.vmName
    adminUsername: virtualmachine.adminUsername
    clientSecret: adminPassword
    osDiskType: virtualmachine.osDiskType
    OSDiskSize: virtualmachine.OSDiskSize
    vmResouceGroupLocation: virtualmachine.vmResouceGroupLocation
    vmSize: virtualmachine.vmSize
    vnetResourceGroup: virtualmachine.vnetResourceGroup
    virtualNetworkName: virtualmachine.virtualNetworkName
    subnetName: virtualmachine.subnetName
    diagstorageName: virtualmachine.diagstorageName
    resourceTags: resourceTags
    timeZone: virtualmachine.timeZone
    dataPath: virtualmachine.dataPath
    logPath: virtualmachine.logPath
    tempDbPath: virtualmachine.tempDbPath
    sqlVirtualMachineName: virtualmachine.sqlVirtualMachineName
    sqlDataDisksCount: virtualmachine.sqlDataDisksCount
    sqlLogDisksCount: virtualmachine.sqlLogDisksCount
  }
  dependsOn: [
    rg
  ]
}]
