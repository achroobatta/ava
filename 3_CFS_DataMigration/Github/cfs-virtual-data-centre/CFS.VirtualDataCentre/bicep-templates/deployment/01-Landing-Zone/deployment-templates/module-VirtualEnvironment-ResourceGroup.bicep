targetScope = 'subscription'

param resourceGroup object
param contributorPrincipalId string
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

// create resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroup.name
  location: resourceGroup.location
  tags: {
    appName: resourceGroup.appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}

// assign contributor permissions
module rgPermissions '../../../modules/Microsoft.Authorization/roleAssignment/resourceGroup/deployContibutorRoleAssignmentToRg.bicep' = {
  name: 'permissions-${rg.name}'
  scope: rg
  params: {
    principalId: contributorPrincipalId
    resourceGroupName: rg.name
  }
}

// assign service principal permissions
