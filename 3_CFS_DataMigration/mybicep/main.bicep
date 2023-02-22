var prefix = 'prod'
var storageName = '${prefix}2020storagenew'
// var regions = [
//   'eastus'
//   'northeurope'
// ]

module storageModule  'storage.bicep' = {
  name: 'storageModule'
  params: {
    storageName: storageName
  }
}

// resource storage123 'Microsoft.Storage/storageAccounts@2022-05-01' = [for (region,i) in regions: {
//   name: '${storageName}${i}' 
//   location: region
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'StorageV2'
//   properties: {
//     accessTier: 'Hot'
//   }
// }]
