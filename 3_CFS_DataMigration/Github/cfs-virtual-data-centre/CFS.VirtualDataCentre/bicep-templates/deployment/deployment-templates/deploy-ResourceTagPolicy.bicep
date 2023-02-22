targetScope = 'managementGroup'

param resouceTagsArray array
param location string

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = [for (rt, i) in resouceTagsArray : {
  name: 'rt.name-${i}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: rt.displayName
    description: rt.description
    enforcementMode: rt.enforcementMode
    metadata: {
      source: 'source'
      version: '0.1.0'
    }
    policyDefinitionId: rt.policyDefinitionId
    parameters: {
      tagName: {
        value: rt.tagName
      }
    }
    nonComplianceMessages: [
      {
        message: rt.message
      }
    ]
    notScopes: []
  }
}]
