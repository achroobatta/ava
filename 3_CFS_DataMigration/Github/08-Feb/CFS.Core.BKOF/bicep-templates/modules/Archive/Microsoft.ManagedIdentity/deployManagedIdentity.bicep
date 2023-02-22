param location string
param maanagedIdentityName string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

// TODO: Check if the permission can be more specific
// get Owner permission using built in assignments
// https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference
// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

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
    name: 'SQL Server Contributor'
    definitionID: '6d8ee4ec-f05a-4a1d-8b00-a9b17e38b437'
  }
  {
    name: 'Virtual Machine Contributor'
    definitionID: '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
  }
  {
    name: 'Key Vault Administrator'
    definitionID: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  }
  {
    name: 'SQL DB Contributor'
    definitionID: '9b7fa17d-e63e-47b0-bb0a-15c516ac86ec'
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

resource mIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: maanagedIdentityName
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }    
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = [for (roleAssignment, i) in roleAssignments: {
  name:  guid(roleAssignment.name,resourceGroup().id)
  properties: {
    principalType: 'ServicePrincipal'
    principalId: mIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.definitionID)
  }
}]

output mIdentityId string = mIdentity.id
output mIdentityClientId string = mIdentity.properties.clientId
