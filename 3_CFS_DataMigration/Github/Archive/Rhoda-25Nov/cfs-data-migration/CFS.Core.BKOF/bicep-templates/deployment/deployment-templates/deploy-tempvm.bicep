targetScope = 'subscription'

@description('Parameter Object for virtual machine module')
param vmObject object

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
@description('The string value for owner tag')
param owner string
@description('The string value for CostCenter tag')
param costCenter string

@description('Environment')
param environmentPrefix string
var EnvironmentUpper = toUpper(environmentPrefix)

@secure()
param adminpassword string

resource rgDeploy 'Microsoft.Resources/resourceGroups@2021-04-01' existing = [for (vm, i) in vmObject.vmValues: {
  name: vm.rgname
}]

@batchSize(1)
module deployVM '../../modules/Microsoft.Compute/deployTempVM.bicep' = [for (vm, i) in vmObject.vmValues: {
  name: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmService}${vm.vmInstancePrefix}${vm.vmInstance}'
  scope: resourceGroup(vm.rgname)
  params: {
      vmResouceGroupLocation: vm.vmRgLocation
      vmName: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmService}${vm.vmInstancePrefix}0${vm.vmInstance}'
      adminUsername: vm.adminUsername
      adminPassword: adminpassword
      osDiskType: vm.osDiskType
      OSDiskSize: vm.osDiskSize
      vmSize: vm.vmSize
      vnetResourceGroup: vm.vnetResourceGroup
      virtualNetworkName: vm.virtualNetworkName
      subnetName: vm.subnetName
      diagstorageName: vm.diagstorageName
      timeZone: vm.timeZone
      privateIPAllocationMethod: vm.privateIPAllocationMethod
      privateIPAddress: vm.privateIPAddress
      imageReferencePublisher: vm.imageReferencePublisher
      imageReferenceOffer: vm.imageReferenceOffer
      imageSKU: vm.imageSKU
      imageReferenceVersion: vm.imageReferenceVersion
      appName: vm.appName
      environmentPrefix: environmentPrefix
      owner: owner
      costCenter: costCenter
      createOnDate: createOnDate
    }
    dependsOn: [
      rgDeploy
    ]
  }]
