targetScope = 'subscription'

param roleAssignmentArray array
param subscriptionId string

module contributorModule '../../modules/Microsoft.Authorization/roleAssignment/subscription/deployContibutorRoleAssignmentToSubscription.bicep' = [for role in roleAssignmentArray: if (contains(role.DisplayName, 'contributor')) {
  name: 'contributor-${role.DisplayName}'
  scope: subscription(subscriptionId)
  params: {
    principalId: role.principalId
    subscriptionId: subscriptionId
  }
}]

module ownerModule '../../modules/Microsoft.Authorization/roleAssignment/subscription/deployOwnerRoleAssignmentToSubscription.bicep' = [for role in roleAssignmentArray: if (contains(role.DisplayName, 'owner')) {
  name: 'owner-${role.DisplayName}'
  scope: subscription(subscriptionId)
  params: {
    principalId: role.principalId
    subscriptionId: subscriptionId
  }
}]

module readerModule '../../modules/Microsoft.Authorization/roleAssignment/subscription/deployReaderRoleAssignmentToSubscription.bicep' = [for role in roleAssignmentArray: if (contains(role.DisplayName, 'reader')) {
  name: 'reader-${role.DisplayName}'
  scope: subscription(subscriptionId)
  params: {
    principalId: role.principalId
    subscriptionId: subscriptionId
  }
}]
