targetScope = 'subscription'

@description('Parameters for role assignment')
param subscriptionID string
param principalId string
param principalType string

var roleAssignmentName1_var = guid(subscriptionID, 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') //Key Vault Secrets Officer
var roleAssignmentName2_var = guid(subscriptionID, '14b46e9e-c2b7-41b4-b07b-48a6ebf60603') //Key Vault Crypto Officer

resource keyVaultSecretOfficer 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =  {
  name: roleAssignmentName1_var
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') //Key Vault Secrets Officer
    principalId: principalId
    principalType: principalType
  }
}
resource KeyVaultCryptoOfficer 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' =  {
  name: roleAssignmentName2_var
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '14b46e9e-c2b7-41b4-b07b-48a6ebf60603') //Key Vault Crypto Officer
    principalId: principalId
    principalType: principalType
  }
}
