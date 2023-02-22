targetScope = 'managementGroup'

param managementGroupId string

var roleDefinitionID = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Specifies the principal ID assigned to the role.')
param objectId string

var roleAssignmentName_var = guid(managementGroupId, objectId, roleDefinitionID)

resource roleAssignmentName 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName_var
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: objectId
  }
}
