targetScope = 'managementGroup'

param listOfAllowedLocations array = [
  'australiaeast'
  'australiasoutheast'
]

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'AllowedLocationResources'
  location: 'australiaeast'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Allow only Australia East and Australia Southeast Location in all resources'
    description: 'This policy will only allow resources to be deployed in Australia East and Australia Southeast only.'
    enforcementMode: 'Default'
    metadata: {
      source: 'source'
      version: '0.1.0'
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
    parameters: {
      listOfAllowedLocations: {
        value: listOfAllowedLocations
      }
    }
    nonComplianceMessages: [
      {
        message: 'message'
      }
    ]
  }
}
