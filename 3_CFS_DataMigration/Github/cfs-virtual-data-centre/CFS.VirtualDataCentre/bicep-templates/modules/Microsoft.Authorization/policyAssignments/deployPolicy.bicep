targetScope = 'managementGroup'

@description('Location of policy')
param location string

@description('Display policy name')
param displayName string

@description('policy name')
param policyName string

@description('Description of the policy')
param policyDescription string

@description('Policy defination ID of the assignment')
param policyDefinitionId string

@description('Optional policy parameters')
param policyParameters object

// add parameters to the properties object only if not null
var properties = union({
  displayName: displayName
  description: policyDescription
  enforcementMode: 'Default'
  policyDefinitionId: policyDefinitionId
}, policyParameters != json('null') && policyParameters != null && policyParameters != {} ? {
  parameters: policyParameters
} : {
})

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: policyName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: properties
}
