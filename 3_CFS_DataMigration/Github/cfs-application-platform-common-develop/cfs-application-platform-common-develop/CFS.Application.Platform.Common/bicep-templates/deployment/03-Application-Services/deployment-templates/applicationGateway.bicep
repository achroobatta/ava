param applicationGatewayName string
param location string
param managedIdentityName string
param managedIdentityResourceGroup string
param virtualNetworkName string
param virtualNetworkResourceGroup string
param subnetName string
param publicIp string
param certName string
param keyVaultName string
param frontEndPrivateIp string
param backEndPrivateIp string
param apimHostName string
param WAFPolicyName string
param WAFPolicyResourceGroup string

@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountSubscriptionId string
param storageAccountName string
param workspaceResourceGroup string
param workspaceSubscriptionId string
param workspaceName string

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

var appGwResourceId = resourceId('Microsoft.Network/applicationGateways', applicationGatewayName)

resource managedIdentity_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' existing = {
  name: managedIdentityName
  scope: resourceGroup(managedIdentityResourceGroup)
}

resource publicIpAddress_resource 'Microsoft.Network/publicIPAddresses@2021-08-01' existing = {
  name: publicIp
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource virtualNetwork_resource 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource WAFPolicy_resource 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-08-01' existing = {
  name: WAFPolicyName
  scope: resourceGroup(WAFPolicyResourceGroup)
}

resource applicationGatewayName_resource 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: applicationGatewayName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity_resource.id}': {}
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetwork_resource.id}/subnets/${subnetName}'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: certName
        properties: {
          keyVaultSecretId: 'https://${keyVaultName}.vault.azure.net/secrets/${certName}'
        }
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIpAddress_resource.id
          }
        }
      }
      {
        name: 'appGwPrivateFrontendIp'
        properties: {
          privateIPAddress: frontEndPrivateIp
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: '${virtualNetwork_resource.id}/subnets/${subnetName}'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: backEndPrivateIp
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'apiHTTPsettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: apimHostName
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
          probe: {
            id: '${appGwResourceId}/probes/httpsProbe'
          }
          trustedRootCertificates: []
        }
      }
    ]
    httpListeners: [
      {
        name: 'api-listener'
        properties: {
          frontendIPConfiguration: {
            id: '${appGwResourceId}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${appGwResourceId}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${appGwResourceId}/sslCertificates/api-cert'
          }
          hostNames: []
          requireServerNameIndication: false
        }
      }
    ]
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: 'routeRule'
        properties: {
          ruleType: 'Basic'
          priority: 1
          httpListener: {
            id: '${appGwResourceId}/httpListeners/api-listener'
          }
          backendAddressPool: {
            id: '${appGwResourceId}/backendAddressPools/backendPool'
          }
          backendHttpSettings: {
            id: '${appGwResourceId}/backendHttpSettingsCollection/apiHTTPsettings'
          }
        }
      }
    ]
    probes: [
      {
        name: 'httpsProbe'
        properties: {
          protocol: 'Https'
          host: apimHostName
          path: '/status-0123456789abcdef'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {}
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
    firewallPolicy: {
      id: WAFPolicy_resource.id
    }
  }
}

resource applicationGatewayName_DiagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${applicationGatewayName}'
  scope: applicationGatewayName_resource
  properties: {
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    storageAccountId: storageAccountId
    workspaceId: workspaceId
  }
  dependsOn: [
    applicationGatewayName_resource
  ]
}
