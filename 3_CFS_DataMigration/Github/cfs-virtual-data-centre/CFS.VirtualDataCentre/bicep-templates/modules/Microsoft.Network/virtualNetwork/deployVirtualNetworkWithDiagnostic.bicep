@description('parameters for Virtual Network')

param vNetName string
param rgLocation string
param vNetAddressSpace string
param resourceTags object

param storageAccountSubscriptionId string
param storageAccountResourceGroup string
param storageAccountName string

param workspaceSubscriptionId string
param workspaceResourceGroup string
param workspaceName string

var workspaceId = '/subscriptions/${workspaceSubscriptionId}/resourceGroups/${workspaceResourceGroup}/providers/Microsoft.OperationalInsights/workspaces/${workspaceName}'
var storageAccountId = '/subscriptions/${storageAccountSubscriptionId}/resourceGroups/${storageAccountResourceGroup}/providers/Microsoft.Storage/storageAccounts/${storageAccountName}'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vNetName
  location: rgLocation
  tags: resourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetAddressSpace
      ]
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${virtualNetwork.name}'
  scope: virtualNetwork
  properties: {
    logs: [
      {
        category: 'VMProtectionAlerts'
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
