targetScope = 'subscription'

@description('Parameter Array for virtual machine module')
param vmArray array

@description('Parameter Array for Resource Group Module')
param rgArray array


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

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (rg, i) in rgArray: {
  name: 'rg-${environmentPrefix}-${(rg.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
  location: rg.vmResouceGroupLocation
  tags: {
    appName: 'Security'
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

@batchSize(1)
module deployVM '../../../modules/Microsoft.Compute/deployVA.bicep' = [for (virtualmachine, i) in vmArray: {
  name: 'VM${EnvironmentUpper}${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'EDC' : 'SDC' }${virtualmachine.vmService}00${virtualmachine.vm_instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${virtualmachine.serviceAbbrv}-${virtualmachine.component}-00${virtualmachine.instance}')
  params: {
    vmResouceGroupLocation: virtualmachine.vmResouceGroupLocation
    vmName: 'VM${EnvironmentUpper}${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'EDC' : 'SDC' }${virtualmachine.vmService}00${virtualmachine.vm_instance}'
    osDiskType: virtualmachine.osDiskType
    osDiskSize: virtualmachine.osDiskSize
    vmSize: virtualmachine.vmSize
    managedDiskID: virtualmachine.managedDiskID
    vnetResourceGroup: 'rg-${environmentPrefix}-${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${virtualmachine.serviceAbbrv}-${virtualmachine.vnet_component}-00${virtualmachine.vnet_instance}'
    virtualNetworkName: 'vnet-${environmentPrefix}-${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${virtualmachine.vnet_serviceAbbrv}-00${virtualmachine.vnet_instance}'
    subnetName: 'sub-${environmentPrefix}-${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${virtualmachine.sn_serviceAbbrv}-00${virtualmachine.vnet_instance}'
    diagstorageName: 'sto${environmentPrefix}${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }${virtualmachine.serviceAbbrv}00${virtualmachine.stor_instance}'
    appName: virtualmachine.appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  dependsOn: [
    rg
  ]
}]
