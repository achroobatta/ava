targetScope = 'managementGroup'

param managementGroupId string

var roleDefinitionID = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'

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

