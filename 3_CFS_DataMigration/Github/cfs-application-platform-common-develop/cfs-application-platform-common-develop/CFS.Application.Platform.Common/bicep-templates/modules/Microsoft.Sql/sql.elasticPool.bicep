param sqlServerName string
param elasticPoolName string
param location string
param skuName string
param tier string
param poolLimit int
param minCapacity int
param maxCapacity int
param poolSize int
param zoneRedundant bool
param licenseType string

param storageAccountId string
param workspaceId string


resource elasticPool_resource 'Microsoft.Sql/servers/elasticPools@2021-11-01-preview' = {
  name: '${sqlServerName}/${elasticPoolName}'
  location: location
  tags: {}
  sku: {
    name: skuName
    tier: tier
    capacity: poolLimit
  }
  properties: {
    perDatabaseSettings: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
    maxSizeBytes: poolSize
    zoneRedundant: zoneRedundant
    licenseType: licenseType
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${elasticPoolName}'
  scope: elasticPool_resource
  properties: {
    metrics: [
      {
        category: 'Basic'
        enabled: true
        retentionPolicy: {
          days: 365
          enabled: true
        }
      }
      {
        category: 'InstanceAndAppAdvanced'
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
