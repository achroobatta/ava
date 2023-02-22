var roleDefinitionID = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Specifies the principal ID assigned to the role.')
param principalId string
param resourceGroupName string

var roleAssignmentName_var = guid(principalId, roleDefinitionID, resourceGroupName)

resource roleAssignmentName 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName_var
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: principalId
  }
}
