targetScope = 'subscription'

param virtualEnvironmentArray array
param storageAccountSubscriptionId string
param workspaceSubscriptionId string

@description('The offset symbol for Australia East used in the dateTimeAdd function: PT10H for AEST, PT11H for AEDT.')
param australiaEastOffsetSymbol string
@description('The string value for owner tag')
param owner string
@description('The string value for CostCenter tag')
param costCenter string
@description('Environment')
param environmentPrefix string

// call a module for each virtual environment in the array
module deployVenv './module-VirtualEnvironment.bicep' =  [for (venv, i) in virtualEnvironmentArray: {
  name: 'venv-${environmentPrefix}-${venv.serviceAbbrv}-${venv.component}-${i}'
  scope: subscription()
  params: {
    australiaEastOffsetSymbol: australiaEastOffsetSymbol
    costCenter: costCenter
    environmentPrefix: environmentPrefix
    owner: owner
    virtualEnvironment: venv
    storageAccountSubscriptionId: storageAccountSubscriptionId
    storageAccountResourceGroup: 'rg-${environmentPrefix}-${(venv.location == 'australiaeast') ? 'edc' : 'sdc' }-sec-stor-001'
    storageAccountName: 'sto${environmentPrefix}${(venv.location == 'australiaeast') ? 'edc' : 'sdc' }diagnlogs00${venv.StorageAccountInstance}'
    workspaceResourceGroup: 'rg-${environmentPrefix}-${(venv.location == 'australiaeast') ? 'edc' : 'sdc' }-sec-sec-001'
    workspaceSubscriptionId: workspaceSubscriptionId
    workspaceName: 'ws-${environmentPrefix}-${(venv.location == 'australiaeast') ? 'edc' : 'sdc' }-001'
  }
}]

