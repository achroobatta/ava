targetScope = 'managementGroup'
param groupName string
param groupDisplayName string
param parentId string
param subscriptionId string

resource mainManagementGroup 'Microsoft.Management/managementGroups@2020-02-01' = {
  name: groupName
  scope: tenant()
  properties: {
    displayName: groupDisplayName
    details: {      
      parent: {
        id: parentId
      }
    }
  }
}

resource subscriptionResources 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = {
  parent: mainManagementGroup
  name: subscriptionId
}
