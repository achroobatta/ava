targetScope = 'managementGroup'

@description('Parameters for policy')
param policyarray array

module deploypolicyExemption '../../modules/Microsoft.Authorization/policyAssignments/deployPolicyExemption.bicep' = [for (policy, i) in policyarray: {
  name: 'deploypolicy-${i}'
  scope: managementGroup(policy.managementGroupScope)
  params: {
    exemptionInstance: policy.exemptionInstance
    exemptionDisplayName: policy.displayName
    exemptionDescription: policy.description
    exemptionCategory: policy.category
    policyAssignmentId: policy.policyAssignmentId
    expiresOn: policy.expiration
  }
}]
