targetScope = 'subscription'

param subscriptionId string

var roleDefinitionID = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'

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
