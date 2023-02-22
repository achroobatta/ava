@description('Provide the name of the Azure Key Vault')
param keyVaultName string

@description('Provide the Tenant ID of the Azure Activ Directory who will handle Key Vault authentication')
param azureTenantId string

@description('Location used will be the same as the resource group')
param keyVaultResourceGroupLocation string

param keyVaultObject object

@description('parameters for key')
param vaultkeyEncryptName string

@description('Parameters for secret')
param localAdminPasswordSecretName string
param localAdminPassword string


@description('Parameters for Diagnostic Log')
param storageAccountResourceGroup string
param storageAccountName string
param workspaceResourceGroup string
param workspaceName string
param storageAccountSubscriptionId string
param workspaceSubscriptionId string


@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)


resource keyVaultResource 'Microsoft.KeyVault/vaults@2019-09-01' = [for kv in keyVaultObject.keyVault : {
  name: '${keyVaultName}-00${kv.instance}'
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
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}]

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (kv,i) in keyVaultObject.keyVault : {
  name: 'diag-${keyVaultResource[i].name}'
  scope: keyVaultResource[i]
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
  dependsOn: [
    keyVaultResource
  ]
}]
resource vaultkeyEncrypt 'Microsoft.KeyVault/vaults/keys@2021-06-01-preview' =[for (kv,i) in keyVaultObject.keyVault : { 
  parent: keyVaultResource[i]
  name: vaultkeyEncryptName
  properties: {
    keySize: 3072
    kty: 'RSA'
    attributes: {
      enabled: true
    }
  }
}]

//create a secret for the local administrator password for VMs
resource localAdminPasswordVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' =[for (kv,i) in keyVaultObject.keyVault : {
  name: localAdminPasswordSecretName
  parent: keyVaultResource[i]
  properties: {
    attributes: {
      enabled: true
      exp: 1619658768
    }
    value: localAdminPassword
  }
}]
