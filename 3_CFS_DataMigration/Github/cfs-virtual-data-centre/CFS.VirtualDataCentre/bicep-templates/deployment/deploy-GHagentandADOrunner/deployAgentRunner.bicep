targetScope = 'subscription'

@description('VM instance Number')
param vmInstanceNumber int

@description('VM Details')
param vm object

@description('For Monitoring Agent')
param workspaceId string

@description('For Monitoring Agent')
param workspaceKey string

@description('The KeyEncryptionUrl in the KeyVault')
param KeyEncryptionUrl string

@secure()
param domainPassword string

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

@description('The int value for the key vault instance')
param kv_instance int

@description('The int value for the key vault resource group instance')
param kv_rg_instance int

@description('The string value for the key vault service component abbreviation')
param kv_serviceAbbrv string

@description('The string value for the key vault service component')
param kv_service string

@allowed([
'ADO'
'GH'
])
@description('The string value for the component of resource group')
param rg_component string

param isTestPoolOrGroup bool

param servicesRequiringAbbreviationForKeyVaultName array = [
	'connectivity'
	'operations'
]


//only accommodate test agents/runners with instance numbers 0-9 (otherwise it breaks the 15-character limit of VM resource name).
var lengthToPad = (isTestPoolOrGroup) ? 1 : 3

//osIdentifier 'W' = 'Windows'.
var osIdentifier = 'W'

//TEST identifier 'T'.
var testIdentifier = (isTestPoolOrGroup) ? 'T' : ''

var rgName = 'rg-${environmentPrefix}-${(vm.vmRgLocation == 'australiaeast') ? 'edc' : 'sdc' }-${vm.vmRgServiceAbbrv}-${rg_component}${osIdentifier}${testIdentifier}-${padLeft(vmInstanceNumber, lengthToPad, '0')}'

var vmName = 'VM${EnvironmentUpper}${(vm.vmRgLocation == 'australiaeast') ? 'EDC' : 'SDC' }${rg_component}${osIdentifier}${testIdentifier}${padLeft(vmInstanceNumber, lengthToPad, '0')}'

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'kv-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${ contains(servicesRequiringAbbreviationForKeyVaultName, kv_service) ? kv_serviceAbbrv : kv_service}-00${kv_instance}'
  scope: resourceGroup('rg-${environmentPrefix}-${(kv_location == 'australiaeast') ? 'edc' : 'sdc' }-${kv_serviceAbbrv}-${kv_component}-00${kv_rg_instance}')
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: vm.vmRgLocation
  tags: {
    appName: vm.appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}

module deployVM '../../modules/Microsoft.Compute/deployVM.bicep' = {
  name: vmName
  scope: resourceGroup(rgName)
  params: {
    vmResouceGroupLocation: vm.vmRgLocation
    vmName: vmName
    adminUsername: vm.adminUsername
    adminPassword: kv.getSecret('cfsadmin')
    osDiskType: vm.osDiskType
    OSDiskSize: vm.osDiskSize
    dataDisks: vm.dataDiskResources
    vmSize: vm.vmSize
    availabilitySetName: vm.availabilitySetName
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
    autoShutdownTime: vm.autoShutdownTime
    isEnableAutoShutdown: (vmInstanceNumber > 1 || isTestPoolOrGroup) //keep always on for the first instance in the mainstream pool/runner group.
    autoShutdownNotificationEmail: vm.autoShutdownNotificationEmail
    domainName: vm.domainName
    domainUserName: vm.domainUserName
    domainPassword: domainPassword // Injected at pipeline using variable group
    isEnableDomainJoin: vm.isEnableDomainJoin
    OUPAth: vm.OUPAth
  }
  dependsOn: [
    rg
    kv
  ]
}

var vmDetails = {
  rgName: rgName
  vmName: vmName
}
output vmOutput object = vmDetails
