@description('Provide the location where storage account will be deployed')
param location string

param storageAccountName string
param storageAccountId string

param workspaceResourceGroup string
param workspaceSubscriptionId string

//load metric alerts to be applied to all storage accounts
var metricAlertsObject = json(loadTextContent('./storageAccount.metricAlerts.json'))

resource actionGroup 'Microsoft.Insights/actionGroups@2022-04-01' existing = {
  name: metricAlertsObject.actionGroupName
  scope: resourceGroup(workspaceSubscriptionId,workspaceResourceGroup)
}

resource metricAlerts 'Microsoft.Insights/metricAlerts@2018-03-01' = [for (metricAlert, i) in metricAlertsObject.metricAlerts: {
  name: '${metricAlert.name} (${storageAccountName})'
  location: 'global'    //must be global
  properties: {
    actions: [
      {
        actionGroupId: actionGroup.id
        webHookProperties: {}
      }
    ]
    autoMitigate: true
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: metricAlert.CriterionType
          dimensions:empty(metricAlert.dimensions)?[]:[ //if not empty
            {
                name: metricAlert.dimensions
                operator: 'Include'
                values: [
                    '*'
                ]
            }
        ]
          metricName: metricAlert.metricName
          metricNamespace: 'string'
          name: 'Metric1'
          operator: metricAlert.operator
          skipMetricValidation: true
          threshold: metricAlert.threshold
          timeAggregation: metricAlert.timeAggregation
        }
      ]
    }
    description: metricAlert.name
    enabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      storageAccountId
    ]
    severity: metricAlert.severity
    targetResourceRegion: location
    targetResourceType: 'Microsoft.Storage/storageAccounts'
    windowSize: 'PT5M'
  }
}]
