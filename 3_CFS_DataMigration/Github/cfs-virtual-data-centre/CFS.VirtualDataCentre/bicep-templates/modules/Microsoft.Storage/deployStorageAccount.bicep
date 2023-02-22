@description('Provide the location where storage account will be deployed')
param location string

@description('Parameter for storage account object')
param storageAccount array

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

param workspaceResourceGroup string
param workspaceSubscriptionId string

resource storageAccountNameArray 'Microsoft.Storage/storageAccounts@2021-06-01' = [for storage in storageAccount : {
  name: storage.storageAccountName
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    publicNetworkAccess: storage.publicNetworkAccess
    minimumTlsVersion: storage.minimumTlsVersion
    allowBlobPublicAccess: storage.allowBlobPublicAccess
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: contains(storage, 'virtualNetworkRules') ? storage.virtualNetworkRules : null
      defaultAction: storage.defaultAction
    }
  }
  sku: {
    name: storage.performance
  }
  kind: storage.kind
}]

resource blobStorageAccountArray 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = [for (storage, i) in storageAccount : if (storage.kind != 'FileStorage') { 
  name: 'default'
  parent: storageAccountNameArray[i]
  properties: {
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 14
    }
  }
}]

resource fileStorageAccountArray 'Microsoft.Storage/storageAccounts/fileServices@2022-05-01' = [for (storage, i) in storageAccount : if (storage.kind == 'FileStorage') { 
  name: 'default'
  parent: storageAccountNameArray[i]
  properties: {
    shareDeleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 14
    }
  }
}]

module metricAlertModule 'storageAccountMetricAlert.bicep' = [ for (sto,i) in storageAccount : {
  name: 'deploy-metric-alert${i}'
  scope: resourceGroup()
  params: {
    location: location
    storageAccountName: storageAccountNameArray[i].name
    storageAccountId: storageAccountNameArray[i].id
    workspaceResourceGroup: workspaceResourceGroup
    workspaceSubscriptionId: workspaceSubscriptionId
  }
}]
