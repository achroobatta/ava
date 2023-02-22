@minLength(3)
@maxLength(24)
@description('Name of the storage account')
param storageAccountName string

param storageContainerName string = 'data'

param identity string
param PublicSubnetId string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
@description('Storage Account Sku')
param storageAccountSku string = 'Standard_LRS'

// @allowed([
//   'Standard'
//   'Premium'
// ])
// @description('Storage Account Sku tier')
// param storageAccountSkuTier string = 'Premium'

@description('UTC timestamp used to create distinct deployment scripts for each deployment')
param utcValue string = utcNow()

var location  = resourceGroup().location

@description('Name of the blob container')
var containerName = 'data'

@description('Name of the blob as it is stored in the blob container')
var filename = 'InstallGatewayOnLocalMachine.ps1'


@description('Enable or disable Blob encryption at Rest.')
param encryptionEnabled bool = true

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  tags: {
    displayName: storageAccountName
    type: 'Storage'
  }
  location: location
  kind: 'StorageV2'  
  identity:  {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity}': {}
    }
  }
  sku: {
    name: storageAccountSku
  }

  properties: {
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    // networkAcls: {
    //   bypass: 'AzureServices'
    //   virtualNetworkRules: [
    //     {
    //       id: PublicSubnetId
    //       action: 'Allow'
    //       state: 'succeeded'
    //     }
    //   ]
    
    //   ipRules: []
    //   defaultAction: 'Deny'
    // }
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: encryptionEnabled
        }
        file: {
          enabled: encryptionEnabled
        }
      }
    }
  } 
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${storageAccountName_resource.name}/default/${storageContainerName}'  
  properties:{
    publicAccess: 'Container'
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-upload-blob-${utcValue}'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity}': {}
    }
  }  
  properties: {
    // storageAccountSettings: {
    //   storageAccountKey: storageAccountName_resource.listKeys().keys[0].value
    //   storageAccountName: storageAccountName
    // }
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storageAccountName
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storageAccountName_resource.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: loadTextContent('../storage/InstallGatewayOnLocalMachine.ps1')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${filename} && az storage blob upload -f ${filename} -c ${containerName} -n ${filename}'
  }
}

var keysObj = listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2021-04-01')
output key1 string = keysObj.keys[0].value
output key2 string = keysObj.keys[1].value
output storageaccount_id string = storageAccountName_resource.id
// output container_obj object = container.
