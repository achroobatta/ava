@description('Parameter Object for virtual machine module')
param vmObject object

@description('For Monitoring Agent')
param workspaceId string

@secure()
param domainPassword string

@description('For Monitoring Agent')
param workspaceKey string

@description('The KeyEncryptionUrl in the KeyVault')
param KeyEncryptionUrl string

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

@description('The string value for the key vault Resource Group instance component')
param kv_rginstance int

@description('The string value for the key vault instance component')
param kv_instance int

@description('The string value for the key vault service component abbreviation')
param kv_serviceAbbrv string

@description('The string value for the key vault service component')
param kv_service string

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'kv-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${(kv_service == 'connectivity') ? 'hub' : kv_service}-00${kv_instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${kv_serviceAbbrv}-${kv_component}-00${kv_rginstance}')
}

@batchSize(1)
module deployVM '../../../modules/Microsoft.Compute/deployIAASVM.bicep' = [for (vm, i) in vmObject.vmValues: {
  name: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmService}${vm.vmInstancePrefix}${vm.vmInstance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(vm.vmRgLocation == 'australiaeast') ? 'edc' : 'sdc' }-${vm.vmRgServiceAbbrv}-${vm.vmRgComponent}-00${vm.vmRgInstance}')
  params: {
    vmResouceGroupLocation: vm.vmRgLocation
    vmName: 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${vm.vmService}${vm.vmInstancePrefix}${vm.vmInstance}'
      adminUsername: vm.adminUsername
      clientSecret: kv.getSecret('cfsadmin')
      osDiskType: vm.osDiskType
      OSDiskSize: vm.osDiskSize
      vmSize: vm.vmSize
      vnetResourceGroup: 'rg-${environmentPrefix}-${(vm.vmRgLocation == 'australiaeast') ? 'edc' : 'sdc' }-${vm.vmRgServiceAbbrv}-${vm.vnetRgComponent}-00${vm.vnetInstance}'
      virtualNetworkName: 'vnet-${environmentPrefix}-${(vm.vmRgLocation == 'australiaeast') ? 'edc' : 'sdc' }-${vm.vnetRgServiceAbbrv}-00${vm.vnetInstance}'
      subnetName: 'sub-${environmentPrefix}-${(vm.vmRgLocation == 'australiaeast') ? 'edc' : 'sdc' }-${vm.snetServiceAbbrv}-00${vm.snetInstance}'
      diagstorageName: 'sto${environmentPrefix}${(vm.vmRgLocation == 'australiaeast') ? 'edc' : 'sdc' }${vm.vmRgServiceAbbrv}00${vm.storageAccInstance}'
      workspaceKey: workspaceKey // Injected at pipeline using Azure CLI Query
      workspaceId: workspaceId // Injected at pipeline using Azure CLI Query
      timeZone: vm.timeZone
      keyVaultURL: 'https://${kv.name}.vault.azure.net'
      keyVaultName_resourceId: kv.id
      KeyEncryptionKeyURL: KeyEncryptionUrl // Injected at pipeline using Azure CLI Query
      KekVaultResourceId: kv.id
      imageReferencePublisher: vm.imageReferencePublisher
      imageReferenceOffer: vm.imageReferenceOffer
      imageSKU: vm.imageSKU
      imageReferenceVersion: vm.imageReferenceVersion
      appName: vm.appName
      environmentPrefix: environmentPrefix
      owner: owner
      costCenter: costCenter
      createOnDate: createOnDate
      dataPath: vm.dataPath
      logPath: vm.logPath
      tempDbPath: vm.tempDbPath
      sqlVirtualMachineName: vm.sqlVirtualMachineName
      sqlDataDisksCount: vm.sqlDataDisksCount
      sqlLogDisksCount: vm.sqlLogDisksCount
      containerName: vm.containerName
      storageAccountName: 'sto${environmentPrefix}${(vm.vmRgLocation == 'australiaeast') ? 'edc' : 'sdc' }${vm.vmRgServiceAbbrv}00${vm.storageAccInstance}'
      RGstorage_account: 'rg-${environmentPrefix}-${(vm.vmRgLocation == 'australiaeast') ? 'edc' : 'sdc' }-${vm.vmRgServiceAbbrv}-${vm.storageAccComponent}-00${vm.vmRgInstance}'
      fullBackupStartTime: vm.fullBackupStartTime
      fullBackupWindowHours: vm.fullBackupWindowHours
      domainName: vm.domainName
      domainUserName: vm.domainUserName
      domainPassword: domainPassword // Injected at pipeline using variale group
      isEnableDomainJoin: vm.isEnableDomainJoin
      OUPAth: vm.OUPAth
    }
    dependsOn: [
      kv
    ]
  }]
