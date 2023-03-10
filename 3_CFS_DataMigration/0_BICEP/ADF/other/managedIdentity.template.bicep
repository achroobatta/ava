param location string
param managedIdentityName string
// TODO: Check if the permission can be more specific
// get Owner permission using built in assignments
// https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference
// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
param ownerRoleDefId string

param tags object


resource mIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
  tags: tags 
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name:  guid(ownerRoleDefId,resourceGroup().id)
  scope: resourceGroup()
  properties: {
    principalType: 'ServicePrincipal'
    principalId: mIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', ownerRoleDefId)
  }
}

output mIdentityId string = mIdentity.id
output mIdentityClientId string = mIdentity.properties.clientId
