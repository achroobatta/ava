targetScope = 'subscription'

param resourceLocation string

@description('Parameter Object for Key Vault')
param kvObj object

@description('User will select where VM will be placed')
param hostPoolType string

param numberOfInstance int
param startingPoint int

param hostPoolName string

param personalObj object
param sharedObj object

@description('Parameter Object for virtual machine module')
param vmObj object

@description('For Monitoring Agent')
param workspaceId string

@description('For Monitoring Agent')
param workspaceKey string

param edcNetworkobj object
param sdcNetworkobj object
param personalSessionHostType string
param sharedSessionHostType string

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
@description('environmentPfx')
param environmentPfx string
param locationPfx string

var EnvPfx = toUpper(environmentPfx)
var LocPfx = toUpper(locationPfx)

param fileSize int
param registrationKey string

param vmLane string

@description('Determine how many VMs will be green and blue')
// var vmRemainder = (numberOfInstance > 2 ) ? numberOfInstance % 2 : 0
// var vmBlueCount = int((vmRemainder != 0 && numberOfInstance > 2) ? numberOfInstance / 2 + vmRemainder : (numberOfInstance > 1) ? numberOfInstance / 2 : numberOfInstance)
// var vmLanes = [for i in range(0, numberOfInstance): ( i > vmBlueCount) ? 'G' : 'B']

// var rgNames = [for vmLane in vmLanes: (vmLane == 'B') ? ((hostPoolType == 'Personal') ? personalObj.blueRgInstance : sharedObj.blueRgInstance) : ((hostPoolType == 'Personal') ? personalObj.greenRgInstance : sharedObj.greenRgInstance)]
// var availInstances = [for vmLane in vmLanes: (vmLane == 'B') ? ((hostPoolType == 'Personal') ? personalObj.blueAvailInstance : sharedObj.blueAvailInstance) : ((hostPoolType == 'Personal') ? personalObj.greenAvailInstance : sharedObj.greenAvailInstance)]

var rgInstance = (vmLane == 'B') ? ((hostPoolType == 'Personal') ? personalObj.blueRgInstance : sharedObj.blueRgInstance) : ((hostPoolType == 'Personal') ? personalObj.greenRgInstance : sharedObj.greenRgInstance)
var availInstance = (vmLane == 'B') ? ((hostPoolType == 'Personal') ? personalObj.blueAvailInstance : sharedObj.blueAvailInstance) : ((hostPoolType == 'Personal') ? personalObj.greenAvailInstance : sharedObj.greenAvailInstance)


//var sessionHostType = (projectPfx == 'dmt') ? ((hostPoolType == 'Personal') ? personalObj.dmtSessionHostType: sharedObj.dmtSessionHostType ): ((hostPoolType == 'Personal') ? personalObj.defaultSessionHostType: sharedObj.defaultSessionHostType)
var ouPath = (locationPfx == 'edc') ? ((hostPoolType == 'Personal') ? personalObj.edcOuPath : sharedObj.edcOuPath) : ((hostPoolType == 'Personal') ? personalObj.sdcOuPath : sharedObj.sdcOuPath)
var sessionHostType = (hostPoolType == 'Personal') ? personalSessionHostType : sharedSessionHostType

var hpRgInstance = (hostPoolType == 'Personal') ? personalObj.HpRgInstance : sharedObj.HpRgInstance
//Refer KeyVault which Contains Domain and Admin Password
resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: kvObj.kvName
  scope: resourceGroup(kvObj.kvRgName)
}

//need to add blue and green deployment code based on blueCount and greenCount, will adjust Code later

module deployVM '../../modules/Microsoft.Avd/deployAvdVM.bicep' = [for i in range(0, numberOfInstance): {
  name: 'deploy-VM${EnvPfx}${LocPfx}VD${sessionHostType}${vmLane}-${i + startingPoint}'
  scope: resourceGroup('rg-${environmentPfx}-${locationPfx}-oper-comp-00${rgInstance}')
  params: {
      vmResouceGroupLocation: resourceLocation
      vmName: 'VM${EnvPfx}${LocPfx}VD${sessionHostType}${vmLane}-${i + startingPoint}'
      adminUsername: vmObj.adminUsername
      adminPassword: kv.getSecret('${kvObj.adminPasswordSecret}')
      osDiskType: vmObj.osDiskType
      OSDiskSize: vmObj.osDiskSize
      vmSize:  vmObj.vmSize
      vnetResourceGroup: (resourceLocation == 'australiaeast') ? edcNetworkobj.vnetRg : sdcNetworkobj.vnetRg
      virtualNetworkName: (resourceLocation == 'australiaeast') ? edcNetworkobj.vnetName : sdcNetworkobj.vnetName
      //subnetName: (resourceLocation == 'australiaeast') ? (projectPfx == 'dmt') ? vmObj.edcDmtSubNm : vmObj.edcDefaultSubNm : (projectPfx == 'dmt') ? vmObj.sdcDmtSubNm : vmObj.sdcDefaultSubNm
      subnetName: (resourceLocation == 'australiaeast') ? edcNetworkobj.subnetName : sdcNetworkobj.subnetName
      timeZone: vmObj.timeZone
      privateIPAllocationMethod: vmObj.privateIPAllocationMethod
      privateIPAddress: vmObj.privateIPAddress
      imageReferencePublisher: vmObj.imageReferencePublisher
      imageReferenceOffer: vmObj.imageReferenceOffer
      imageSKU: vmObj.imageSKU
      imageReferenceVersion: vmObj.imageReferenceVersion
      appName: appName
      environmentPrefix: environmentPfx
      owner: owner
      costCenter: costCenter
      createOnDate: createOnDate
      workspaceId:workspaceId
      workspaceKey:workspaceKey
      dataDisks:vmObj.dataDiskResources
      dataDisksCount:  fileSize % 128 == 0 ? fileSize/128 : int(fileSize/128) + 1 //This line requires modification, because their is limitation on disk count
      availabilitySetName: 'avail-${environmentPfx}-${locationPfx}-avd-00${availInstance}'
      domainName: vmObj.domainName
      domainUserName: vmObj.domainUserName
      domainPassword:  kv.getSecret('${kvObj.domainPasswordSecret}') // read it from keyvault and supply here
      isEnableDomainJoin: vmObj.isEnableDomainJoin
      OUPAth:  ouPath
      aadJoin: true
      hostPoolName: hostPoolName
      hpRg: 'rg-${environmentPfx}-${locationPfx}-oper-comp-00${hpRgInstance}'
      registrationKey: registrationKey
      configUrl: vmObj.configUrl
      isEnableAutoShutdown: vmObj.isEnableAutoShutdown
      autoShutdownTime: vmObj.autoShutdownTime
      autoShutdownNotificationEmail:vmObj.autoShutdownNotificationEmail
    }
  }]
