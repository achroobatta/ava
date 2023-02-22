@description('Data Factory Name')
param dataFactoryName string

@description('Location of the data factory.')
param location string

@description('Name of the Azure storage account that contains the input/output data.')
param storageAccountName string

@description('Name of the blob container in the Azure Storage account.')
param blobContainerName string

var dataFactoryLinkedServiceName = 'templateStorageLinkedService'
var dataFactoryDataSetInName = 'templateTestDatasetIn'
var dataFactoryDataSetOutName = 'templateTestDatasetOut'
var pipelineName = 'templateSampleCopyPipeline'

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource storageAccountName_default_blobContainerName 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${storageAccountName}/default/${blobContainerName}'
  dependsOn: [
    storageAccountName_resource
  ]
}

resource dataFactoryName_resource 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    publicNetworkAccess:'Disabled'
  }
}

resource dataFactoryName_dataFactoryLinkedServiceName 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactoryName_resource
  name: dataFactoryLinkedServiceName
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(storageAccountName_resource.id, '2021-08-01').keys[0].value}'
    }
  }
}

resource dataFactoryName_dataFactoryDataSetInName 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactoryName_resource
  name: dataFactoryDataSetInName
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedServiceName
      type: 'LinkedServiceReference'
    }
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        container: blobContainerName
        folderPath: 'input'
      }
    }
  }
  dependsOn: [
    dataFactoryName_dataFactoryLinkedServiceName
  ]
}

resource dataFactoryName_dataFactoryDataSetOutName 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactoryName_resource
  name: dataFactoryDataSetOutName
  properties: {
    linkedServiceName: {
      referenceName: dataFactoryLinkedServiceName
      type: 'LinkedServiceReference'
    }
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        container: blobContainerName
        folderPath: 'output'
      }
    }
  }
  dependsOn: [
    dataFactoryName_dataFactoryLinkedServiceName
  ]
}

resource dataFactoryName_pipelineName 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactoryName_resource
  name: pipelineName
  properties: {
    activities: [
      {
        name: 'MyCopyActivity'
        type: 'Copy'
        typeProperties: {
          source: {
            type: 'BinarySource'
            storeSettings: {
              type: 'AzureBlobStorageReadSettings'
              recursive: true
            }
          }
          sink: {
            type: 'BinarySink'
            storeSettings: {
              type: 'AzureBlobStorageWriteSettings'
            }
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: dataFactoryDataSetInName
            type: 'DatasetReference'
          }
        ]
        outputs: [
          {
            referenceName: dataFactoryDataSetOutName
            type: 'DatasetReference'
          }
        ]
      }
    ]
  }
  dependsOn: [
    dataFactoryName_dataFactoryDataSetOutName
    dataFactoryName_dataFactoryDataSetInName
  ]
}
