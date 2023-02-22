targetScope = 'subscription'

@description('The virtual environment to create')
param virtualEnvironment object

@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountSubscriptionId string
param storageAccountName string
param workspaceResourceGroup string
param workspaceSubscriptionId string
param workspaceName string

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
@description('The string value for owner tag')
param owner string
@description('The string value for CostCenter tag')
param costCenter string
@description('Environment')
param environmentPrefix string

// TODO we can get the serviceAbbrv from the subscription name
var regionPrefix = (virtualEnvironment.location == 'australiaeast') ? 'edc' : 'sdc'

// create the array of resource groups we will create
// need to validate here that there's no conflict with the existing resource groups in the subscription... TODO ...
var rgArray = [for i in range (1, virtualEnvironment.count): {
  name: 'rg-${environmentPrefix}-${regionPrefix}-${virtualEnvironment.serviceAbbrv}-${virtualEnvironment.component}-00${i}'
  location: virtualEnvironment.location
  serviceAbbrv: virtualEnvironment.serviceAbbrv
  component: virtualEnvironment.component
  appName: virtualEnvironment.appName
  instance: i  
}]

// call a module for each resource group
module venv './module-VirtualEnvironment-ResourceGroup.bicep' = [for (rg, i) in rgArray: {
  name: rg.name
  scope: subscription()
  params: {
    australiaEastOffsetSymbol: australiaEastOffsetSymbol
    costCenter: costCenter
    environmentPrefix: environmentPrefix
    owner: owner
    resourceGroup: rg
    contributorPrincipalId: virtualEnvironment.contributorPrincipalId
  }
}]

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

// create the subnet
// and associated Route tables and nsgs
module subnet './module-VirtualEnvironment-Subnet.bicep' = {
  name: 'subnet'
  scope: resourceGroup(virtualEnvironment.vnetNetResourceGroup)
  params: {
    virtualEnvironment: virtualEnvironment
    regionPrefix: regionPrefix
    australiaEastOffsetSymbol: australiaEastOffsetSymbol
    costCenter: costCenter
    environmentPrefix: environmentPrefix
    owner: owner
    storageAccountId: storageAccountId
    workspaceId: workspaceId
  }
}

// create the service principal


// assign permissions to 'standard' resources - e.g. KeyVault, Storage, Recovery Services


