targetScope = 'managementGroup'

@description('Parameters for policy')
param policyarray array

module deploypolicy '../../modules/Microsoft.Authorization/policyAssignments/deployPolicy.bicep' = [for (policy, i) in policyarray: {
  name: 'deploypolicy-${i}'
  params: {
    location: policy.location
    displayName: policy.displayName
    policyDescription: policy.policyDescription
    policyDefinitionId: policy.policyDefinitionId
    policyName: policy.policyName
    policyParameters: policy.parameters
  }
}]
