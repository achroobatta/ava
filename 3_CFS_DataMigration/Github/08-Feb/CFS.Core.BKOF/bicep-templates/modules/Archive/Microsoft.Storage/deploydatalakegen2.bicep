param dllocation string = resourceGroup().location

@description('Parameter for storage account object')
param storageAccount array

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

resource dlStorageAccountNameArray 'Microsoft.Storage/storageAccounts@2021-08-01' = [for storage in storageAccount :{
  name: storage.dlstorageAccountName
  location: dllocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  sku: {
    name: storage.performance
  }
  kind: storage.kind
  properties: {
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices,Logging,Metrics' 
      virtualNetworkRules: contains(storage, 'virtualNetworkRules') ? storage.virtualNetworkRules : null
      defaultAction: storage.defaultAction
      /*
      virtualNetworkRules: [for vnetSubnetResourceId in vnetSubnetResourceIds: {
        id: vnetSubnetResourceId
        action: 'Allow'
      }]
      ipRules: [for dlWhiteListip in dlWhiteListedIps: {
        value: dlWhiteListip
        action: 'Allow'
      }]
      */
      /*
      virtualNetworkRules: [{
        id: vnetSubnetResourceId
        action: 'Allow'
      }]
      ipRules: [{
        value: dlWhiteListip
        action: 'Allow'
      }]
      */
    }
    publicNetworkAccess: storage.publicNetworkAccess
    minimumTlsVersion: storage.minimumTlsVersion
    allowBlobPublicAccess: storage.allowBlobPublicAccess
    supportsHttpsTrafficOnly: storage.supportsHttpsTrafficOnly
    allowSharedKeyAccess: storage.allowSharedKeyAccess
    isHnsEnabled: storage.isHnsEnabled
    largeFileSharesState: storage.largeFileSharesState
    isNfsV3Enabled: storage.isNfsV3Enabled
  }
}]

resource dlStorageBlobArray 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = [for (storage, i) in storageAccount : {
  parent: dlStorageAccountNameArray[i]
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    isVersioningEnabled: false
    lastAccessTimeTrackingPolicy: {
      enable: true
      name: 'AccessTimeTracking'
      trackingGranularityInDays: 1
    }
  }
  dependsOn: dlStorageAccountNameArray
}]

resource dlStorageContainerArray 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [for (storage, i) in storageAccount: {
  parent: dlStorageBlobArray[i]
  name: storage.dlRootContainterName
  dependsOn: dlStorageBlobArray
}]
