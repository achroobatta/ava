@description('Provide the name of the Azure Key Vault')
param keyVaultName string

@description('Provide the Tenant ID of the Azure Activ Directory who will handle Key Vault authentication')
param azureTenantId string

@description('Location used will be the same as the resource group')
param keyVaultResourceGroupLocation string

// @description('parameters for key')
// param vaultkeyEncryptName string

// @description('Parameters for secret')
// param localAdminPasswordSecretName string
// param localAdminPassword string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

param virtualNetworkResourceGroup string
param virtualNetworkName string
param virtualNetworksubnetName string
param defaultAction string

param enabledForDeployment bool
param enabledForDiskEncryption bool
param enabledForTemplateDeployment bool
param enableSoftDelete bool
param enablePurgeProtection bool
param enableRbacAuthorization bool
param publicNetworkAccess string

@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountName string
param workspaceResourceGroup string
param workspaceName string
param storageAccountSubscriptionId string
param workspaceSubscriptionId string
param virtualNetworkRules array
param action string

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)


resource keyVaultResource 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: keyVaultResourceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    tenantId: azureTenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableSoftDelete: enableSoftDelete
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      bypass: 'AzureServices'
      // virtualNetworkRules: [{
      //   id: resourceId(virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, virtualNetworksubnetName)
      // }]
      virtualNetworkRules: [for (vr,i) in virtualNetworkRules: {
        id: resourceId(vr.virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vr.virtualNetworkName_RG, vr.virtualNetworksubnetName)
        action: action
      }]
      defaultAction: defaultAction
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${keyVaultResource.name}'
  scope: keyVaultResource
  properties: {
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzurePolicyEvaluationDetails'
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


/*
resource vaultkeyEncrypt 'Microsoft.KeyVault/vaults/keys@2021-06-01-preview' = {
  parent: keyVaultResource
  name: vaultkeyEncryptName
  properties: {
    keySize: 3072
    kty: 'RSA'
    attributes: {
      enabled: true
    }
  }
}

//create a secret for the local administrator password for VMs
resource localAdminPasswordVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: localAdminPasswordSecretName
  parent: keyVaultResource
  properties: {
    attributes: {
      enabled: true
      exp: 1619658768
    }
    value: localAdminPassword
  }
}
*/
