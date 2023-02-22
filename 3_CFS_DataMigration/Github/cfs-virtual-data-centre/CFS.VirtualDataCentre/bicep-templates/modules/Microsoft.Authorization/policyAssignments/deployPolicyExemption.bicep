targetScope = 'managementGroup'

@allowed([
  'Mitigated'
  'Waiver'
])
param exemptionCategory string

@description('Sets the Policy expiration date')
param expiresOn string
param expiresOnUtc string = utcNow(expiresOn)
var expiresOnConvert = replace(expiresOnUtc,'Z','')

@description('Sets the Policy Id')
param policyAssignmentId string

@description('Sets the Policy Exemption description value')
param exemptionDescription string

@description('Sets the Policy Exemption Display Name')
param exemptionDisplayName string

@description('Sets the Policy Exemption Id')
param exemptionInstance int

resource policyExemption 'Microsoft.Authorization/policyExemptions@2020-07-01-preview' = {
  name: '${exemptionInstance}'
  scope: managementGroup()
  properties: {
    description: exemptionDescription
    displayName: exemptionDisplayName
    exemptionCategory: exemptionCategory
    policyAssignmentId: policyAssignmentId
    expiresOn: !empty(expiresOn) ? expiresOnConvert : null
  }
}
