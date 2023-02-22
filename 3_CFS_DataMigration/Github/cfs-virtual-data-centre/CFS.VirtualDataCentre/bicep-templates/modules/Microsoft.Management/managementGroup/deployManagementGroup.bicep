targetScope = 'managementGroup'

param groupName string
param groupDisplayName string
param instance int
param environmentPrefix string
param subscriptionIds array
param parentId string

resource mainManagementGroup 'Microsoft.Management/managementGroups@2020-02-01' = {
  name: 'mg-${environmentPrefix}-${groupName}-00${instance}'
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
resource subscriptionResources 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = [for sub in subscriptionIds: {
  parent: mainManagementGroup
  name: sub.id
}]
output groupId string = mainManagementGroup.id
