targetScope = 'subscription'

param environmentPrefix string
param resourceGroupObject object

param utcNowFormatted string = utcNow('yyyy-MM-dd HH:mm:ss')
var australiaEastNowFormatted = dateTimeAdd(utcNowFormatted, australiaEastOffsetSymbol)
var createOnDate = replace(australiaEastNowFormatted,'Z','')

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string

@description('The string value for owner tag')
param owner string

@description('The string value for CostCenter tag')
param costCenter string

param sftpUserName string 

param sftpRootContainterName string

param sshKeyName string

// param sftpWhiteListip string
param ipTobeWhiteListed string

var sftpWhiteListedIps = split(ipTobeWhiteListed,',')

//var contributorRoleDefId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@batchSize(1)
module storageAccount '../../modules/Microsoft.Storage/deploysftpnew.bicep' = [for rg in resourceGroupObject.resourceGroups: {
  name: 'sftpsto${environmentPrefix}${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }${(rg.serviceAbbrv == 'sec') ? 'diagnlogs' : rg.serviceAbbrv }-00${rg.instance}'
  scope: resourceGroup(rg.rgname)
  //scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.instance}')
  params: {
    appName: rg.appName
    costCenter: costCenter
    createOnDate: createOnDate
    environmentPrefix: environmentPrefix
    owner: owner
    storageAccount: rg.storageAccount
    sftplocation: rg.location
    sftpUserName: sftpUserName
    sftpRootContainterName: sftpRootContainterName
    sshKeyName: sshKeyName
    sftpWhiteListedIps: sftpWhiteListedIps
    virtualNetworkResourceGroup: rg.virtualNetworkResourceGroup
    virtualNetworkName_RG: rg.virtualNetworkRGName
    virtualNetworksubnetName: rg.virtualNetworksubnetName
  }
}]
