targetScope = 'subscription'

@description('Parameter Object for virtual machine module')
param vmObject object

@description('Parameter Array for Resource Group Module')
param rgArray array

@description('Parameter Array for Storage Module')
param storageArray array

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
// var EnvironmentUpper = toUpper(environmentPrefix)

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

param fileSize string

param vnetRG string

var fileSizeArr = split(fileSize,' ')

var fileSizeInt = int(fileSizeArr[0])
var fileSizeType = fileSizeArr[1]

var fileSizeValue = fileSizeInt
// var fileSizeValue = (fileSizeType == 'TB') ? fileSizeInt : (fileSizeType == 'GB') ? fileSizeInt/1000 : (fileSize == 'MB') ? fileSizeInt/1000000 : (fileSizeType == 'KB') ? fileSizeInt/1000000000 : fileSizeInt

// var uniqueSubString = uniqueString(guid(subscription().subscriptionId, '1234567890'))
// var usubString = toUpper(substring(uniqueSubString,0,6))
// param buildId int 
param dmVmName string

param diagStorageAcctName string
param resourceLocation string
param privateEndpointNameForStorage string
param ultraSSDEnabled bool
// var subscriptionId  = '0caf2912-0197-4ea5-968d-f517c90d5930'
resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'kv-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${(kv_service == 'connectivity') ? 'hub' : kv_service}-00${kv_instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${kv_serviceAbbrv}-${kv_component}-00${kv_rginstance}')
}

// resource sa 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
//    name: 'dlgen2npedcbkof1000'
//    scope: subscriptionResourceId(subscriptionId,  )
// }

resource rgresource 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (rg, i) in rgArray: {
  // name: 'rg-${environmentPrefix}-${(rg.vmResouceGroupLocation == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
  // location: rg.vmResouceGroupLocation
  name: 'rg-${environmentPrefix}-${(resourceLocation == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}'
  location: resourceLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}]

@batchSize(1)
module storageAccount '../../modules/Microsoft.Storage/deployDiagStorageAccount.bicep' = [for (rg, i) in storageArray: {
  name: 'deploy${diagStorageAcctName}'
  scope: resourceGroup((resourceLocation == 'australiaeast') ? rg.rgname: rg.rgname2)
  params: {
    location: (resourceLocation == 'australiaeast') ? rg.location : rg.location2
    appName: appName
    environmentPrefix: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    //containerPrefix: rg.containerPrefix
    storageAccountName: diagStorageAcctName
    publicNetworkAccess: rg.publicNetworkAccess
    minimumTlsVersion: rg.minimumTlsVersion
    allowBlobPublicAccess: rg.allowBlobPublicAccess
    defaultAction: rg.defaultAction      
    performance: rg.performance
    kind: rg.kind
  }
  dependsOn: rgresource
}] 

@batchSize(1)
module privateendpointforstorageDeploy '../../modules/Microsoft.Network/privateEndpoints/privateEndpoints_diagstorage.bicep' = [for rg in storageArray: {
  scope: resourceGroup((resourceLocation == 'australiaeast') ? rg.rgname: rg.rgname2)
  name: 'pvedeploy-${privateEndpointNameForStorage}'
  params: {
    location: (resourceLocation == 'australiaeast') ? rg.location : rg.location2
    storageName: diagStorageAcctName
    subnetName: (resourceLocation == 'australiaeast') ? rg.subnetName : rg.subnet2Name
    virtualNetworkName: (resourceLocation == 'australiaeast') ? rg.virtualNetworkName : rg.virtualNetwork2Name
    virtualNetworkResourceGroup: (resourceLocation == 'australiaeast') ? rg.virtualNetworkResourceGroup : rg.virtualNetwork2ResourceGroup
    privateDnsZoneName: rg.privateDnsZoneName
    appName: appName
    costCenter: costCenter
    createOnDate: createOnDate
    owner: owner
    environmentPrefix: environmentPrefix
    storageRG: rg.rgname    
    privateEndpointNameForStorage: privateEndpointNameForStorage
  }
  dependsOn: [
    rgresource
    storageAccount
  ]
}]

@batchSize(1)
module deployVM '../../modules/Microsoft.Compute/deployVM.bicep' = [for (vm, i) in vmObject.vmValues: if (ultraSSDEnabled == false){
  //name: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmService}${vm.vmInstancePrefix}${vm.vmInstance}'
  name: 'Deploy${dmVmName}'
  scope: resourceGroup(vm.rgname)
  params: {
      vmResouceGroupLocation: resourceLocation
      //vmResouceGroupLocation: vm.vmRgLocation
      // vmName: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmInstancePrefix}${buildId}'
      vmName: dmVmName
      adminUsername: vm.adminUsername
      adminPassword: adminPassword
      osDiskType: vm.osDiskType
      OSDiskSize: vm.osDiskSize
      vmSize: (fileSizeType == 'TB') ? (fileSizeValue <= vm.fileSize ? vm.vmSmallSize : vm.vmLargeSize) : (fileSizeType == 'KB' ? (fileSizeValue <= vm.fileSize ? vm.vmSmallSize: vm.vmLargeSize) : vm.vmSmallSize)
      vnetResourceGroup: vm.vnetResourceGroup
      virtualNetworkName: vm.virtualNetworkName
      subnetName: vm.subnetName
      diagstorageName: diagStorageAcctName
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
      dataDisksCount: (fileSizeType == 'TB') ? ((fileSizeValue % 16 != 0) ? ((int(fileSizeValue/16) + 1) + 5*(int(fileSizeValue/16) + 1)) : (int(fileSizeValue/16) + 5*int(fileSizeValue/16))) : 6
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
      storageAccount
      privateendpointforstorageDeploy
    ]
  }]

@batchSize(1)
module deployVMude '../../modules/Microsoft.Compute/deployVMude.bicep' = [for (vm, i) in vmObject.vmValues: if (ultraSSDEnabled == true && resourceLocation == 'australiaeast') {
  //name: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmService}${vm.vmInstancePrefix}${vm.vmInstance}'
  name: 'Deploy${dmVmName}-ultraSSDEnabled'
  scope: resourceGroup(vm.rgname)
  params: {
      vmResouceGroupLocation: resourceLocation
      //vmResouceGroupLocation: vm.vmRgLocation
      // vmName: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmInstancePrefix}${buildId}'
      vmName: dmVmName
      adminUsername: vm.adminUsername
      adminPassword: adminPassword
      osDiskType: vm.osDiskType
      OSDiskSize: vm.osDiskSize
      vmSize: (fileSizeType == 'TB') ? (fileSizeValue <= vm.fileSize ? vm.vmSmallSize : vm.vmLargeSize) : (fileSizeType == 'KB' ? (fileSizeValue <= vm.fileSize ? vm.vmSmallSize: vm.vmLargeSize) : vm.vmSmallSize)
      vnetResourceGroup: vm.vnetResourceGroup
      virtualNetworkName: vm.virtualNetworkName
      subnetName: vm.subnetName
      diagstorageName: diagStorageAcctName
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
      dataDisksCount: (fileSizeType == 'TB') ? ((fileSizeValue % 16 != 0) ? ((int(fileSizeValue/16) + 1) + 5*(int(fileSizeValue/16) + 1)) : (int(fileSizeValue/16) + 5*int(fileSizeValue/16))) : 6
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
      storageAccount
      privateendpointforstorageDeploy
    ]
  }]
