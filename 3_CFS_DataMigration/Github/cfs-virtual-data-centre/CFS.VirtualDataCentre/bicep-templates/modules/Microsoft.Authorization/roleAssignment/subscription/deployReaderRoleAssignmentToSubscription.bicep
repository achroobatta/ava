targetScope = 'subscription'

param subscriptionId string

var roleDefinitionID = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

@description('Specifies the principal ID assigned to the role.')
param principalId string

var roleAssignmentName_var = guid(subscriptionId, principalId, roleDefinitionID)

resource roleAssignmentName 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName_var
  properties: {
    roleDefinitionId: subscriptionResourceId(subscriptionId, 'Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: principalId
  }
}
