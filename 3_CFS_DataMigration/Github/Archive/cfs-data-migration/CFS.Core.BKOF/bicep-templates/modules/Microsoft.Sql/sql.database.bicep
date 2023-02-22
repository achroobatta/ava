param elasticPoolName string
param elasticPoolResourceGroup string
param sqlServerName string
param databaseName string
param location string
var collation = 'SQL_Latin1_General_CP1_CI_AS'
var sqlDbSkuName = 'ElasticPool'
param sqlDbTierName string = 'GeneralPurpose'

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

param storageAccountId string
param workspaceId string

param workspaceSubscriptionId string
param workspaceResourceGroup string

//load metric alerts to be applied to all storage accounts
var metricAlertsObject = json(loadTextContent('./sql.metricAlerts.json'))

var actionGroup = resourceId(workspaceSubscriptionId,workspaceResourceGroup, 'Microsoft.Insights/actionGroups', metricAlertsObject.actionGroupName)

resource elasticPool_resource 'Microsoft.Sql/servers/elasticPools@2021-11-01-preview' existing = {
  name: elasticPoolName
  scope: resourceGroup(elasticPoolResourceGroup)
}

resource sqlServer_resource 'Microsoft.Sql/servers@2021-08-01-preview' existing = {
  name: sqlServerName
}

resource serverName_databaseName 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  name: '${sqlServerName}/${databaseName}'
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  } 
  properties: {
    collation: collation
    elasticPoolId: '${sqlServer_resource.id}/elasticPools/${elasticPoolName}'
  }
  sku: {
    name: sqlDbSkuName
    tier: sqlDbTierName
  }
  dependsOn: [
    sqlServer_resource
    elasticPool_resource
  ]
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${databaseName}'
  scope: serverName_databaseName
  properties: {
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AutomaticTuning'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'Errors'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'Timeouts'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'Blocks'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'Deadlocks'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'WorkloadManagement'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
    ]
    storageAccountId: storageAccountId
    workspaceId: workspaceId
  }
}

resource metricAlerts 'microsoft.insights/metricAlerts@2018-03-01' = [for (metricAlert, i) in metricAlertsObject.metricAlerts: {
  name: '${metricAlert.name} (${databaseName})'
  location: 'global'
  properties: {
    severity: metricAlert.severity
    enabled: true
    scopes: [
      serverName_databaseName.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: metricAlert.threshold
          name: 'Metric1'
          metricNamespace: 'string'
          metricName: metricAlert.metricName
          operator: metricAlert.operator
          skipMetricValidation: true
          timeAggregation: metricAlert.timeAggregation 
          criterionType: metricAlert.CriterionType 
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: metricAlert.name
    autoMitigate: true
    targetResourceType: 'Microsoft.Sql/servers/databases'
    targetResourceRegion: location
    actions: [
      {
        actionGroupId: actionGroup
        webHookProperties: {}
      }
    ]
  }
}]
