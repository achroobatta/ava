targetScope = 'subscription'

param principalId string

module deployKVSecretOfficer '../../modules/Microsoft.Compute/deployRoleAssignmentsSI.bicep' = {
  name: 'roleAssignmentKV'
  scope: subscription()
  params: {
    principalId: principalId
  }
}
