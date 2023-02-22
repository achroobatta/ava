@description('Parameters for Firewall Resource')
param location string
param rgName string
param vnetName string
param azureFirewallName string 
param firewallPolicyname string
param azureFirewallTier string
param isFirewallAZenable bool
param isForceTunnelingEnabled bool

@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountSubscriptionId string
param storageAccountName string
param workspaceResourceGroup string
param workspaceSubscriptionId string
param workspaceName string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

//load metric alerts to be applied to all storage accounts
var metricAlertsObject = json(loadTextContent('./firewall.metricAlerts.json'))

resource actionGroup 'Microsoft.Insights/actionGroups@2022-04-01' existing = {
  name: metricAlertsObject.actionGroupName
  scope: resourceGroup(workspaceSubscriptionId,workspaceResourceGroup)
}

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

resource firewallPublicIp_resource 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-${azureFirewallName}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  zones: contains(location, 'australiaeast' ) ? [
    '3'
    '2'
    '1'
  ] : null
}

resource firewallPolicy_resource 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: firewallPolicyname
}

resource azureFirewallName_resource 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: azureFirewallName
  location: location
  zones: (isFirewallAZenable == true) ? [
    '3'
    '2'
    '1'
  ]: null
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
        name: firewallPublicIp_resource.name
        properties: {
          subnet: {
            id: resourceId(rgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureFirewallSubnet')
          }
          publicIPAddress: (isForceTunnelingEnabled == false ) ? {
            id: resourceId(rgName, 'Microsoft.Network/publicIPAddresses', firewallPublicIp_resource.name)
          }: null
        }
      }
    ]
    sku: {
      tier: azureFirewallTier
    }
    managementIpConfiguration: (isForceTunnelingEnabled == true) ? {
      name: 'pip-forcetunnelling'
      properties: {
        subnet: {
          id: resourceId(rgName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureFirewallManagementSubnet')
        }
        publicIPAddress: {
          id: resourceId(rgName, 'Microsoft.Network/publicIPAddresses', firewallPublicIp_resource.name)
        }
      }
    } : null
    firewallPolicy: {
      id: firewallPolicy_resource.id
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${azureFirewallName}'
  scope: azureFirewallName_resource
  properties: {
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzureFirewallDnsProxy'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWNetworkRule'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWApplicationRule'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWNatRule'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWThreatIntel'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWIdpsSignature'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWDnsQuery'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWFqdnResolveFailure'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWApplicationRuleAggregation'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWNetworkRuleAggregation'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AZFWNatRuleAggregation'
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

resource metricAlerts 'microsoft.insights/metricAlerts@2018-03-01' = [for (metricAlert, i) in metricAlertsObject.metricAlerts: {
  name: '${metricAlert.name} (${azureFirewallName_resource.name})'
  location: 'global'
  properties: {
    severity: metricAlert.severity
    enabled: true
    scopes: [
      azureFirewallName_resource.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: metricAlert.threshold
          name: 'Metric1'
          metricNamespace: 'Microsoft.Network/azureFirewalls'
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
    targetResourceType: 'Microsoft.Network/azureFirewalls'
    targetResourceRegion: location
    actions: [
      {
        actionGroupId: actionGroup.id
        webHookProperties: {}
      }
    ]
  }
}]


