targetScope = 'subscription'

@description('Parameter Array for virtual machine module')
param vmObject object

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

@description('The string value for the key vault resource group location')
param kv_location string

@description('The string value for the key vault service component abbreviation')
param kv_component string

@description('The string value for the key vault instance component')
param kv_instance int

@description('The string value for the key vault service component abbreviation')
param kv_serviceAbbrv string

@description('The string value for the key vault service component')
param kv_service string

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'kv-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${(kv_service == 'connectivity') ? 'hub' : kv_service}-00${kv_instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${kv_serviceAbbrv}-${kv_component}-00${kv_instance}')
}

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
module deployVM '../../../modules/Microsoft.Compute/deployQualysVM.bicep' = [for (virtualmachine, i) in vmObject.vmValues: {
  name: 'VM${EnvironmentUpper}${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'EDC' : 'SDC' }${virtualmachine.vmService}00${virtualmachine.vmInstanceNumber}'
  scope: resourceGroup('rg-${environmentPrefix}-${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${virtualmachine.serviceAbbrv}-${virtualmachine.component}-00${virtualmachine.rgInstanceNumber}')
  params: {
    vmName: 'VM${EnvironmentUpper}${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'EDC' : 'SDC' }${virtualmachine.vmService}00${virtualmachine.vmInstanceNumber}'
    vmResouceGroupLocation: virtualmachine.vmResouceGroupLocation
    vmSize: virtualmachine.vmSize
    publisher: virtualmachine.publisher
    offer: virtualmachine.offer
    sku: virtualmachine.sku
    version: virtualmachine.version
    osDiskSize: virtualmachine.OSDiskSize
    osDiskType: virtualmachine.osDiskType
    dataDiskSize: virtualmachine.dataDiskSize
    dataDiskType: virtualmachine.dataDiskType
    adminUsername: virtualmachine.adminUsername
    adminPassword: kv.getSecret('cfsadmin')
    perscode: virtualmachine.perscode
    vnetResourceGroup: 'rg-${environmentPrefix}-${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${virtualmachine.serviceAbbrv}-${virtualmachine.vnet_component}-00${virtualmachine.vnet_instance}'
    virtualNetworkName: 'vnet-${environmentPrefix}-${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${virtualmachine.vnet_serviceAbbrv}-00${virtualmachine.vnet_instance}'
    subnetName: 'sub-${environmentPrefix}-${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${virtualmachine.sn_serviceAbbrv}-00${virtualmachine.snet_instance}'
    diagstorageName: 'sto${environmentPrefix}${(virtualmachine.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }${virtualmachine.serviceAbbrv}00${virtualmachine.stor_instance}'
    privateIPAllocationMethod: virtualmachine.privateIPAllocationMethod
    privateIPAddress: virtualmachine.privateIPAddress
    isPublicIp: virtualmachine.isPublicIp
    isPublicIpNew: virtualmachine.isPublicIpNew
    appName: virtualmachine.appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  dependsOn: [
    rg
    kv
  ]
}]
