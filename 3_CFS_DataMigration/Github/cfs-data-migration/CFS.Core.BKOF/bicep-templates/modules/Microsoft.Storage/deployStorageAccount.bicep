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

param virtualNetworkResourceGroup string
param virtualNetworkName_RG string
param virtualNetworksubnetName string 

param containerPrefix string

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
      bypass: 'AzureServices,Logging,Metrics'
      //virtualNetworkRules: contains(storage, 'virtualNetworkRules') ? storage.virtualNetworkRules : null
      virtualNetworkRules: [{
        id: resourceId(virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName_RG, virtualNetworksubnetName)            
        action: storage.action
      }]
      defaultAction: storage.defaultAction

    }
  }
  sku: {
    name: storage.performance
  }
  kind: storage.kind
}]

resource blobStorageAccountArray 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = [for (storage, i) in storageAccount : { 
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

resource blobStorageContainerArray 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [for (storage, i) in storageAccount :{
  parent: blobStorageAccountArray [i]
  //name: storage.dlRootContainterName
  name: '${containerPrefix}container'
}]
