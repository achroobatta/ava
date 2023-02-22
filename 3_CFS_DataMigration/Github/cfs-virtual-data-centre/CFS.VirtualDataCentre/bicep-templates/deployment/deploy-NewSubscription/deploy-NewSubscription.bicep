targetScope = 'tenant'
 
@description('Provide the full resource ID of billing scope to use for subscription creation.')
param billingScope string

@description('The instance number')
param instance int

@description('The name of the main group')
param mainManagementGroupName string

@description('The name for the sub main group')
param subManagementGroupName string

@description('The display name for the sub main group')
param subManagementGroupDisplayName string

@description('The array parameters for management group and subscription')
param managementGroups array

@description('Environment')
param environmentPrefix string

resource mainManagementGroup 'Microsoft.Management/managementGroups@2021-04-01' existing = {
  name: mainManagementGroupName
  scope: tenant()
}

resource subManagementGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: subManagementGroupName
  scope: tenant()
  properties: {
    displayName: subManagementGroupDisplayName
    details: {      
      parent: {
        id: mainManagementGroup.id
      }
    }
  }
}

@batchSize(1)
module subsModule '../../modules/Microsoft.Subscription/aliases/deploySubscription.bicep' = [for group in managementGroups: {
  name: 'subscriptionDeploy-subsc-${environmentPrefix}-${group.name}-${instance}' 
  params: {
    subscriptions: group.subscriptions
    environmentPrefix: environmentPrefix
    instance: instance
    billingScope: billingScope
  }
}]

@batchSize(1)
module mgSubModule '../../modules/Microsoft.Management/managementGroup/deployManagementGroup.bicep' = [for (group, i) in managementGroups: {
  name: 'managementGroupDeploy-mg-${environmentPrefix}-${group.name}-${instance}'
  scope: managementGroup(subManagementGroupName)
  params: {
    groupName: group.name
    groupDisplayName: group.displayName
    environmentPrefix: environmentPrefix
    instance: instance
    parentId: subManagementGroup.id
    subscriptionIds: subsModule[i].outputs.subscriptionIds
  }
  dependsOn: [
    subsModule
  ]
}]
