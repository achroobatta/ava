
param principalId string

param vmName string

var roleAssignments = [
  {
    name: 'Contributor'
    definitionID: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    name: 'Storage Blob Data Contributor'
    definitionID: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  } 
  {
     name: 'Storage Account Contributor'
     definitionID: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  }
  {
    name: 'Key Vault Secrets Officer'
    definitionID: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  }
  {
    name: 'Key Vault Crypto Officer'
    definitionID: '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
  }
]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = [for (roleAssignment, i) in roleAssignments: {
  name:  guid(roleAssignment.name, resourceGroup().id, vmName)     
  properties: {
    principalType: 'ServicePrincipal'
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.definitionID)
  }
}]
