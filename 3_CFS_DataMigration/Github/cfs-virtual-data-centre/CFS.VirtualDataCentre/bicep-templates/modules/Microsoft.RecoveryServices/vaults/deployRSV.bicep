param rsvName string
param location string

@description('Parameters for Diagnostic Log')
param storageAccountSubscriptionId string
param storageAccountResourceGroup string
param storageAccountName string
param workspaceSubscriptionId string
param workspaceResourceGroup string
param workspaceName string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

var storageAccountId = resourceId(storageAccountSubscriptionId, storageAccountResourceGroup, 'Microsoft.Storage/storageAccounts', storageAccountName)
var workspaceId = resourceId(workspaceSubscriptionId, workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName)

resource recoveryServiceVault 'Microsoft.RecoveryServices/vaults@2021-08-01' = {
  name: rsvName
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties:{}
}

resource recoveryVaultName_Microsoft_Insights_diagName 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${rsvName}'
  scope: recoveryServiceVault
  properties: {
    logs: [
      {
        category: 'AzureBackupReport'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'CoreAzureBackup'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AddonAzureBackupJobs'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AddonAzureBackupAlerts'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AddonAzureBackupPolicy'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AddonAzureBackupStorage'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AddonAzureBackupProtectedInstance'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzureSiteRecoveryJobs'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzureSiteRecoveryEvents'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzureSiteRecoveryReplicatedItems'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzureSiteRecoveryReplicationStats'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzureSiteRecoveryRecoveryPoints'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzureSiteRecoveryReplicationDataUploadRate'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'AzureSiteRecoveryProtectedDiskDataChurn'
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
