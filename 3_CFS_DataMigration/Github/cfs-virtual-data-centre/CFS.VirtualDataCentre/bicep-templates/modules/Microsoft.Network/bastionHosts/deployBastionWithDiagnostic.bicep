@description('Name of new or existing vnet to which Azure Bastion should be deployed')
param vnetName string
param bastion_host_name string
param location string
param rgName string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountSubscriptionId string
param storageAccountName string
param workspaceResourceGroup string
param workspaceSubscriptionId string
param workspaceName string

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

//load metric alerts to be applied to all bastion hosts
var metricAlertsObject = json(loadTextContent('./bastion.metricAlerts.json'))

resource public_ip_address_name 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: 'pip-${bastion_host_name}'
  location: location
  sku: {
    name: 'Standard'
  }
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vnet_name_bastion_subnet_name 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' existing = {
  name: '${vnetName}/AzureBastionSubnet'
  scope: resourceGroup(rgName)
}

resource actionGroup 'Microsoft.Insights/actionGroups@2022-04-01' existing = {
  name: metricAlertsObject.actionGroupName
  scope: resourceGroup(workspaceSubscriptionId,workspaceResourceGroup)
}

resource bastion_host_name_resource 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: bastion_host_name
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: vnet_name_bastion_subnet_name.id
          }
          publicIPAddress: {
            id: public_ip_address_name.id
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet_name_bastion_subnet_name
  ]
}


resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${bastion_host_name_resource.name}'
  scope: bastion_host_name_resource
  properties: {
    logs: [
      {
        category: 'BastionAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
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

resource metricAlerts 'Microsoft.Insights/metricAlerts@2018-03-01' = [for metricAlert in metricAlertsObject.metricAlerts: {
  name: '${metricAlert.name} (${bastion_host_name_resource.name})'
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
      bastion_host_name_resource.id
    ]
    severity: metricAlert.severity
    targetResourceRegion: location
    targetResourceType: 'Microsoft.Network/bastionHosts'
    windowSize: 'PT5M'
  }
}]
