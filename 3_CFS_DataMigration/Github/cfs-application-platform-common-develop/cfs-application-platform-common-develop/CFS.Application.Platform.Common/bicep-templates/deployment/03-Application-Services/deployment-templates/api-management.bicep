@description('Name of the APIM service')
param apimName string

@description('APIM Service SKU')
@allowed([
  'Developer'
  'Standard'
  'Premium'
  'Basic'
  'Consumption'
])
param skuName string

@description('Use 0 as SKU Capacity for SKU of Consumption')
param skuCapacity int

@description('Email address of the APIM publisher')
param publisherEmail string

@description('Name of the APIM publisher')
param publisherName string

@description('An email format which will be used as a sender name')
param notificationSenderEmail string

@description('Resource Group of the Virtual Network')
param virtualnetworkResourceGroup string

@description('Virtual network name resource where the subnet of APIM deployment is')
param virtualNetworkName string

@description('Subnet name within the virtual network name resource')
param subnetName string

@description('This is the location where to deploy the Application Insight')
param location string

@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountSubscriptionId string
param storageAccountName string
param workspaceResourceGroup string
param workspaceSubscriptionId string
param workspaceName string

var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)
var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)


resource virtualNetwork_resource 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualnetworkResourceGroup)
}

resource apimName_resource 'Microsoft.ApiManagement/service@2019-12-01' = {
  name: apimName
  location: location
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    notificationSenderEmail: notificationSenderEmail
    virtualNetworkConfiguration: {
      subnetResourceId: '${virtualNetwork_resource.id}/subnets/${subnetName}'
    }
    virtualNetworkType: 'Internal'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource apimName_Microsoft_Insights_diagName 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${apimName}'
  scope: apimName_resource
  properties: {
    storageAccountId: storageAccountId
    workspaceId: workspaceId
    logs: [
      {
        category: 'GatewayLogs'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'WebSocketConnectionLogs'
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
  }
  dependsOn: [
    apimName_resource
  ]
}
