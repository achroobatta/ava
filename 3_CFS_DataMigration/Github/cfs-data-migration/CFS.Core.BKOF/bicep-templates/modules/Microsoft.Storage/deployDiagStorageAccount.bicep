@description('Provide the location where storage account will be deployed')
param location string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

// param virtualNetworkResourceGroup string
// param virtualNetworkName_RG string
// param virtualNetworksubnetName string

//param containerPrefix string
param storageAccountName string
param publicNetworkAccess string
param minimumTlsVersion string
param allowBlobPublicAccess bool
param defaultAction string
param performance string
param kind string

resource storageAccountNameMain 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    minimumTlsVersion: minimumTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices,Logging,Metrics'
      //virtualNetworkRules: contains(storage, 'virtualNetworkRules') ? storage.virtualNetworkRules : null
      // virtualNetworkRules: [{
      //   id: resourceId(virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName_RG, virtualNetworksubnetName)            
      //   action: storageAccount.action
      // }]
      defaultAction: defaultAction      
    }
  }
  sku: {
    name: performance
  }
  kind: kind
}

resource blobStorageAccountMain 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = { 
  name: 'default'
  parent: storageAccountNameMain
  properties: {
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 14
    }
  }
}

// resource blobStorageContainerArray 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
//   parent: blobStorageAccountMain 
//   //name: storage.dlRootContainterName
//   name: '${containerPrefix}container'
// }
