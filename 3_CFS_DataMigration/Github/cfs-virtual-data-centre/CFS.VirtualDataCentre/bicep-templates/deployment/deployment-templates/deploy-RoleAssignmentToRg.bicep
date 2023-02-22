// Not currently being used in production only in non-production

targetScope = 'subscription'

param principalId string = 'f36c0e30-ff48-43bb-a52b-d62d810e5988'
param roleDefinitionName string = 'Owner'
param resourceGroupName string = 'Cfspreviewtest-resource-group'

var contributor = [
  'Contributor'
]

var owner = [
  'Owner'
]

var reader = [
  'Reader'
]

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: resourceGroupName
}

module contributorModule '../../modules/Microsoft.Authorization/roleAssignment/resourceGroup/deployContibutorRoleAssignmentToRg.bicep' = if (contains(contributor, roleDefinitionName)) {
  name: 'deploy-contributor-module'
  scope: rg
  params: {
    principalId: principalId
    resourceGroupName: resourceGroupName
  }
}

module ownerModule '../../modules/Microsoft.Authorization/roleAssignment/resourceGroup/deployOwnerRoleAssignmentToRg.bicep' = if (contains(owner, roleDefinitionName)) {
  name: 'deploy-owner-module'
  scope: rg
  params: {
    principalId: principalId
    resourceGroupName: resourceGroupName
  }
}

module readerModule '../../modules/Microsoft.Authorization/roleAssignment/resourceGroup/deployReaderRoleAssignmentToRg.bicep' = if (contains(reader, roleDefinitionName)) {
  name: 'deploy-reader-module'
  scope: rg 
  params: {
    principalId: principalId
    resourceGroupName: resourceGroupName
  }
}
