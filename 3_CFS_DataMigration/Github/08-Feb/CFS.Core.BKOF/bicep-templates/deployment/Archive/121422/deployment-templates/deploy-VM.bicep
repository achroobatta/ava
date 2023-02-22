targetScope = 'subscription'

@description('Parameter Object for virtual machine module')
param vmObject object

@description('Parameter Array for Resource Group Module')
param rgArray array

@description('For Monitoring Agent')
param workspaceId string

@description('For Monitoring Agent')
param workspaceKey string

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
@description('The string value for owner tag')
param owner string
@description('The string value for CostCenter tag')
param costCenter string
@description('The string value for appName tag')
param appName string

@description('Environment')
param environmentPrefix string
var EnvironmentUpper = toUpper(environmentPrefix)

@secure()
param adminPassword string

@description('The string value for the key vault resource group location')
param kv_location string

@description('The string value for the key vault service component abbreviation')
param kv_component string

@description('The string value for the key vault Resource Group instance component')
param kv_rginstance int

@description('The string value for the key vault instance component')
param kv_instance int

@description('The string value for the key vault service component abbreviation')
param kv_serviceAbbrv string

@description('The string value for the key vault service component')
param kv_service string

@description('The KeyEncryptionUrl in the KeyVault')
param KeyEncryptionUrl string

@secure()
param domainPassword string

param fileSize int

param vnetRG string

// var uniqueSubString = uniqueString(guid(subscription().subscriptionId, '1234567890'))
// var usubString = toUpper(substring(uniqueSubString,0,6))
// param buildId int 
param dmVmName string

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'kv-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${(kv_service == 'connectivity') ? 'hub' : kv_service}-00${kv_instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${kv_serviceAbbrv}-${kv_component}-00${kv_rginstance}')
}

resource rgresource 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (rg, i) in rgArray: {
  name: 'rg-${environmentPrefix}-${(rg.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
  location: rg.vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

@batchSize(1)
module deployVM '../../modules/Microsoft.Compute/deployVM.bicep' = [for (vm, i) in vmObject.vmValues: {
  name: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmService}${vm.vmInstancePrefix}${vm.vmInstance}'
  scope: resourceGroup(vm.rgname)
  params: {
      vmResouceGroupLocation: vm.vmRgLocation
      // vmName: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmInstancePrefix}${buildId}'
      vmName: dmVmName
      adminUsername: vm.adminUsername
      adminPassword: adminPassword
      osDiskType: vm.osDiskType
      OSDiskSize: vm.osDiskSize
      vmSize: fileSize <= 10 ? vm.vmSmallSize : vm.vmLargeSize
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
      appName: appName
      environmentPrefix: environmentPrefix
      owner: owner
      costCenter: costCenter
      createOnDate: createOnDate
      workspaceId:workspaceId
      workspaceKey:workspaceKey
      keyVaultURL: 'https://${kv.name}.vault.azure.net'
      keyVaultName_resourceId: kv.id
      KeyEncryptionKeyURL: KeyEncryptionUrl // Injected at pipeline using Azure CLI Query
      KekVaultResourceId: kv.id
      autoShutdownNotificationEmail:vm.autoShutdownNotificationEmail
      isEnableAutoShutdown:vm.isEnableAutoShutdown
      dataDisks:vm.dataDiskResources
      dataDisksCount: (fileSize % 16 != 0) ? ((int(fileSize/16) + 1) + 5*(int(fileSize/16) + 1)) : (int(fileSize/16) + 5*int(fileSize/16))
      autoShutdownTime:vm.autoShutdownTime
      availabilitySetName: vm.availabilitySetName
      domainName: vm.domainName
      domainUserName: vm.domainUserName
      domainPassword: domainPassword // Injected at pipeline using variable group
      isEnableDomainJoin: vm.isEnableDomainJoin
      OUPAth: vm.OUPAth
      vnetRG: vnetRG
    }
    dependsOn: [
      rgresource
    ]
  }]

  // module deployRole '../../modules/Microsoft.Compute/deployRoleAssignmentsSI.bicep'  = {
  //   name:  'roleAssignmentforSI'
  //   params:{
  //     principalId: deployVM[0].outputs.PrincipalId   
  //     vnetRG: vnetRG 
  //   }   
  //   scope: resourceGroup(vmObject.vmValues[0].rarg)
  // }

// output Vname string = deployVM[0].outputs.VirtualMachineName
