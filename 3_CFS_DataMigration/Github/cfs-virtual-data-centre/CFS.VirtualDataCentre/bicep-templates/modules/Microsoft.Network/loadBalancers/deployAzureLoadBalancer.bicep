param loadBalancerObject object

@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountName string
param workspaceResourceGroup string
param workspaceName string
param storageAccountSubscriptionId string
param workspaceSubscriptionId string

@description('Parameters for resource tags')
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

resource loadBalancerName_resource 'Microsoft.Network/loadBalancers@2020-11-01' = [for lb in loadBalancerObject.loadBalancer : {
  name: lb.loadBalancerName
  location: lb.location
  tags: {
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: contains(lb, 'frontendIPConfigurations')  ? lb.frontendIPConfigurations : null
    backendAddressPools: [
      {
        name: lb.backendPoolName
        properties: {
          loadBalancerBackendAddresses: contains(lb, 'loadBalancerBackendAddresses') ? lb.loadBalancerBackendAddresses : null
        }
      }
    ]
    loadBalancingRules: contains(lb, 'loadBalancingRules') ? lb.loadBalancingRules : null
    probes: contains(lb, 'probes') ? lb.probes : null
    inboundNatRules: contains(lb, 'inboundNatRules') ? lb.inboundNatRules : null
    outboundRules: contains(lb, 'outboundRules') ? lb.outboundRules : null
    inboundNatPools: contains(lb, 'inboundNatPools') ? lb.inboundNatPools : null
  }
}]

resource loadBalancerName_bep_resource 'Microsoft.Network/loadBalancers/backendAddressPools@2022-01-01' = [for (lb, i) in loadBalancerObject.loadBalancer : {
  name: lb.backendPoolName
  parent: loadBalancerName_resource[i]
  properties: {
    loadBalancerBackendAddresses: lb.loadBalancerBackendAddresses
  }
  dependsOn: loadBalancerName_resource
}]

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (lb, i) in loadBalancerObject.loadBalancer : {
  name: 'diag-${lb.loadBalancerName}'
  scope: loadBalancerName_resource[i]
  properties: {
    logs: []
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
}]

module metricAlertModule 'loadBalancerMetricAlert.bicep' = [for (lb, i) in loadBalancerObject.loadBalancer : {
  name: 'deploy-metric-alert${i}'
  scope: resourceGroup()
  params: {
    location: loadBalancerName_resource[i].location
    loadBalancerName: loadBalancerName_resource[i].name
    loadBalancerId: loadBalancerName_resource[i].id
    workspaceResourceGroup: workspaceResourceGroup
    workspaceSubscriptionId: workspaceSubscriptionId
  }
}]
