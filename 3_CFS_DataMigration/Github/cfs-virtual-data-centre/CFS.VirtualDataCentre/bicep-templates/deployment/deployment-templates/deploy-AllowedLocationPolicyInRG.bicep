targetScope = 'managementGroup'

param listOfAllowedLocations array = [
  'australiaeast'
  'australiasoutheast'
]

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'AllowedLocationRG'
  location: 'australiaeast'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Allow only Australia East and Australia Southeast Location in all resource groups'
    description: 'This policy will only allow resource groups to be deployed in Australia East and Australia Southeast only.'
    enforcementMode: 'Default'
    metadata: {
      source: 'source'
      version: '0.1.0'
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
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
