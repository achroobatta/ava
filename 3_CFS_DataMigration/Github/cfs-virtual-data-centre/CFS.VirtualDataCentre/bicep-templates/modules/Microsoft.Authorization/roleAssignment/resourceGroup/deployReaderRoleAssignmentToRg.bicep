var roleDefinitionID = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

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
