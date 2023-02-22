param dllocation string = resourceGroup().location

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string
param deleteByDate string

param virtualNetworkResourceGroup string
param virtualNetworkName_RG string
param virtualNetworksubnetName string
param dlstorageAccountName string
param dlRootContainterName string

param performance string
param kind string
param action string
param defaultAction string

param publicNetworkAccess string
param minimumTlsVersion string
param allowBlobPublicAccess bool
param supportsHttpsTrafficOnly bool
param allowSharedKeyAccess bool
param isHnsEnabled bool
param largeFileSharesState string
param isNfsV3Enabled bool


resource dlStorageAccountNameArray 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: dlstorageAccountName
  location: dllocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    deleteByDate: deleteByDate
  }
  sku: {
    name: performance
  }
  kind: kind
  properties: {
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices,Logging,Metrics' 
      virtualNetworkRules: [{
        id: resourceId(virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName_RG, virtualNetworksubnetName)            
        action: action
      }]
      defaultAction: defaultAction
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
    publicNetworkAccess: publicNetworkAccess
    minimumTlsVersion: minimumTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowSharedKeyAccess: allowSharedKeyAccess
    isHnsEnabled: isHnsEnabled
    largeFileSharesState: largeFileSharesState
    isNfsV3Enabled: isNfsV3Enabled
  }
}

resource dlStorageBlobArray 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: dlStorageAccountNameArray
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
}

resource dlStorageContainerArray 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  parent: dlStorageBlobArray
  //name: storage.dlRootContainterName
  name: dlRootContainterName
}
