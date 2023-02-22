targetScope = 'resourceGroup'
param actionGroupName string
param scopes array
param activityLogAlertsObject object
param tags object
param name string

param location string

//TODO make this flexible enough to accept multiple actiongroups
//TODO remove hardcoded subscription for scopes
resource actionGroup 'Microsoft.Insights/actionGroups@2022-04-01' existing = {
  name: actionGroupName
  scope: resourceGroup()
}

resource activityLogAlerts 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enabled: activityLogAlertsObject.enabled
    scopes: scopes
    actions: {
      actionGroups: [
        {
          actionGroupId: actionGroup.id
          webhookProperties: {}
        }
      ]
    }
    condition: {
      allOf: activityLogAlertsObject.conditions
    }

  }
}
