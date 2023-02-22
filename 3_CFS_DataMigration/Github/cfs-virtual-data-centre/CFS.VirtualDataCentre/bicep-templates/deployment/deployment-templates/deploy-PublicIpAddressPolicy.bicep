targetScope = 'managementGroup'

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'DenyPublicIpAddress'
  location: 'australiaeast'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Network interfaces should not have public IPs'
    description: 'This policy denies the network interfaces which are configured with any public IP. Public IP addresses allow internet resources to communicate inbound to Azure resources, and Azure resources to communicate outbound to the internet. This should be reviewed by the network security team.'
    enforcementMode: 'Default'
    metadata: {
      source: 'source'
      version: '0.1.0'
    }
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114'
    parameters: {}
    nonComplianceMessages: [
      {
        message: 'message'
      }
    ]
  }
}
