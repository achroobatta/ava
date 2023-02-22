targetScope = 'subscription'

@description('Parameters for key vault auth')
param roleAssignArray array
param subscriptionID string

module KeyVaultRoleAssignSecret '../../modules/Microsoft.KeyVault/deployKeyVaultAuth.bicep' = [for (roleAssign, i) in roleAssignArray: {
  name: 'KeyVaultRoleAssignSecret-${i}'
  params: {
    principalId: roleAssign.principalId
    principalType: roleAssign.principalType
    subscriptionID: subscriptionID
  }
}]
