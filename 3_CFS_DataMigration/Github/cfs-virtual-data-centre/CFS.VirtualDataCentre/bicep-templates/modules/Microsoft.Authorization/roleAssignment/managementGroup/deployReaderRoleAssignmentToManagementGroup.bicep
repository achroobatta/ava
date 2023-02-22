targetScope = 'managementGroup'

param managementGroupId string

var roleDefinitionID = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

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
