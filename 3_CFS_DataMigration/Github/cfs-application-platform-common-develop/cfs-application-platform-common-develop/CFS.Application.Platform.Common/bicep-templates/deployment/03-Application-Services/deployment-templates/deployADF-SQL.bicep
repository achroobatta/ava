@description('Specifies the location for resources.')
param location string

param sqlServerTest_name string
param dfName string

@description('Parameter Array for SQL database properties')
param sqlServerArray array

resource sqlServerTest 'Microsoft.Sql/servers@2021-08-01-preview' = {
  name: sqlServerTest_name
  location: location
  properties: {
    administratorLogin: 'dfuser'
    administratorLoginPassword: 'Github1234.'
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource sqlServerTest_dbName 'Microsoft.Sql/servers/databases@2021-08-01-preview' = [for (sq, i) in sqlServerArray: {
  parent: sqlServerTest
  name: sq.dbName
  location: location
  sku: {
    name: sq.skuName
    tier: sq.skuTier
    family: sq.family
    capacity: sq.capacity
  }
  properties: {
    collation: sq.propCollation
    maxSizeBytes: sq.maxSizeBytes
    catalogCollation: sq.propCollation
    zoneRedundant: sq.zoneRedundant
    readScale: sq.readScale
    autoPauseDelay: sq.autoPauseDelay
    requestedBackupStorageRedundancy: sq.requestedBackupStorageRedundancy
    minCapacity: sq.minCapacity
    maintenanceConfigurationId: sq.maintenanceConfigurationId
    isLedgerOn: sq.isLedgerOn
  }
}]


resource df 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dfName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
   publicNetworkAccess:'Disabled'
 }
} 

resource managedVnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  parent:df
  name: 'default'
  properties: {

  }
  dependsOn: [
    azureIntegrationRuntime
  ]
}

resource managedPrivateEndpoint 'Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints@2018-06-01' = {
  parent:managedVnet
  name: 'testManagedVnet-${sqlServerTest_name}-pe'
  properties: {
    privateLinkResourceId: sqlServerTest.id
    groupId: 'sqlServer'
  }
}

resource azureIntegrationRuntime 'Microsoft.DataFactory/factories/IntegrationRuntimes@2018-06-01' = {
  parent: df
  name: '${dfName}-managedVnetIr' 
  properties: {
   type: 'Managed'
   typeProperties: {
     computeProperties: {
       location: 'Australia East'
       dataFlowProperties: {
         computeType: 'General'
         coreCount: 8
         timeToLive: 10
         cleanup: false
       }
     }
   }
 }
}
