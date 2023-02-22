@description('Parameter for VNET object')
param vnetObject object
param vnetName string
param vnetPeerings array = []

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

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

var specialSubnet = [
  'GatewaySubnet'
  'AzureBastionSubnet'
  'AzureFirewallSubnet'
  'AzureFirewallManagementSubnet'
  'SDWANPeeringAddresses1'
  'SDWANPeeringAddresses2'
]

resource ddos_protection_plan 'Microsoft.Network/ddosProtectionPlans@2022-01-01' existing = if (!empty(vnetObject.ddosProtectionPlan)) {
  name: vnetObject.ddosProtectionPlan
  scope: resourceGroup(vnetObject.ddosProtectionPlanRg)
}

resource virtualNetwork_resource 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: vnetObject.location
  properties: {
    addressSpace: {
      addressPrefixes: vnetObject.addressSpaces
    }
    dhcpOptions: {
      dnsServers: vnetObject.customDnsServers
    }
    enableDdosProtection: !empty(vnetObject.ddosProtectionPlan)
    ddosProtectionPlan: !empty(vnetObject.ddosProtectionPlan) ? {
      id: ddos_protection_plan.id
    } : null
    virtualNetworkPeerings: vnetPeerings
    subnets: [for subnet in vnetObject.subnets: {
      name: (contains(specialSubnet, subnet.name))  ? subnet.name : 'sub-${environmentPrefix}-${(subnet.location == 'australiaeast') ? 'edc' : 'sdc' }-${subnet.service}-00${subnet.instance}'
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: !empty(subnet.networkSecurityGroup) ? { 
          id: resourceId('Microsoft.Network/networkSecurityGroups', (contains(specialSubnet, subnet.name))  ? 'nsg-${subnet.name}' : 'nsg-${environmentPrefix}-${(subnet.location == 'australiaeast') ? 'edc' : 'sdc' }-${subnet.service}-00${subnet.instance}')
        } : null
        routeTable: !empty(subnet.routeTable) ? {
          id: resourceId('Microsoft.Network/routeTables', (contains(specialSubnet, subnet.name))  ? 'rt-${subnet.name}' : 'rt-${environmentPrefix}-${(subnet.location == 'australiaeast') ? 'edc' : 'sdc' }-${subnet.service}-00${subnet.instance}')
        } : null
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : null
        delegations: contains(subnet, 'delegations') ? subnet.delegations : null
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
        privateLinkServiceNetworkPolicies: subnet.privateLinkServiceNetworkPolicies
        
      }
    }]
  }
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
}


resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${virtualNetwork_resource.name}'
  scope: virtualNetwork_resource
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

