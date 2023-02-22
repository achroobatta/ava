param WAFPolicyName string
param firewallMode string
param state string = 'Enabled'
param location string

resource wafName_resource 'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies@2021-05-01' = {
  name: WAFPolicyName
  location: location
  tags: {}
  properties: {
    customRules: []
    policySettings: {
      fileUploadLimitInMb: 100
      maxRequestBodySizeInKb: 128
      mode: firewallMode
      requestBodyCheck: true
      state: state
    }
    managedRules: {
      exclusions: []
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
          ruleGroupOverrides: []
        }
      ]
    }
  }
}
