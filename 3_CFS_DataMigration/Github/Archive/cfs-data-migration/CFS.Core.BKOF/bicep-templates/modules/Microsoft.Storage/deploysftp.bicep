param sftplocation string = resourceGroup().location

@description('Parameter for storage account object')
param storageAccount array

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

//param sftpBlobInventoryName string
//param sftpmanagementPolicyName string
//param sftpStgAcctAnalyticsWorkspaceName string

//param vnetSubnetResourceId string
//param sftpWhiteListip string
/*
param vnetSubnetResourceIds array = [
  '<insert vnet subnet resource id here (service endpoint enabled for Microsoft.Storage>'
]
@description('An array of IPv4 addresses to be whitelisted for access to this SFTP storage account and container. Do not specify RFC 1918 addresses nor CIDRs smaller than /30. This should be a list of the IPs representing machines at the other end of the SFTP transfer.')
param sftpWhiteListedIps array = [
  '<insert IP here>'
]
*/

//param sshPublicKey string

resource sftpStorageAccountNameArray 'Microsoft.Storage/storageAccounts@2021-08-01' = [for storage in storageAccount :{
  name: storage.sftpstorageAccountName
  location: sftplocation
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
      ipRules: [for sftpWhiteListip in sftpWhiteListedIps: {
        value: sftpWhiteListip
        action: 'Allow'
      }]
      */
      /*
      virtualNetworkRules: [{
        id: vnetSubnetResourceId
        action: 'Allow'
      }]
      ipRules: [{
        value: sftpWhiteListip
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
    isSftpEnabled: storage.isSftpEnabled
    largeFileSharesState: storage.largeFileSharesState
    isNfsV3Enabled: storage.isNfsV3Enabled
  }
}]

resource sftpStorageBlobArray 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = [for (storage, i) in storageAccount : {
  parent: sftpStorageAccountNameArray[i]
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
  dependsOn: sftpStorageAccountNameArray
}]

resource sftpStorageContainerArray 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [for (storage, i) in storageAccount: {
  parent: sftpStorageBlobArray[i]
  name: storage.sftpRootContainterName
  dependsOn: sftpStorageBlobArray
}]

resource sftpLocalUser 'Microsoft.Storage/storageAccounts/localUsers@2021-09-01' = [for (storage, i) in storageAccount :{
  name: storage.sftpUserName
  parent: sftpStorageAccountNameArray[i]
  dependsOn: sftpStorageAccountNameArray
  properties: {
    permissionScopes: [
      {
        permissions: 'rcwdl'
        service: 'blob'
        resourceName: storage.sftpRootContainterName
      }
    ]
    homeDirectory: '${storage.sftpRootContainterName}'
    /*
    sshAuthorizedKeys: [
      {
        description: 'SSH public key to authenticate with a connection originative from either sftpWhiteListedIps or VnetSubnetResourceIds'
        key: sshPublicKey
      }
    ]
    */
    hasSharedKey: false
  }
}]
/*
resource sftpStorageBlobManagementPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2021-06-01' = {
  name: 'default'
  parent: sftpStorageAccount
  dependsOn: [
    sftpStorageBlob
  ]
  properties: {
    policy: {
      rules: [
        {
          name: sftpmanagementPolicyName
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                delete: {
                  daysAfterLastAccessTimeGreaterThan: 30
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
          }
        }
      ]
    }
  }
}

resource sftpStorageBlobInventoryPolicy 'Microsoft.Storage/storageAccounts/inventoryPolicies@2021-06-01' = {
  name: 'default'
  parent: sftpStorageAccount
  dependsOn: [
    sftpStorageBlob::sftpStorageContainer
  ]
  properties: {
    policy: {
      enabled: true
      type: 'Inventory'
      rules: [
        {
          destination: sftpRootContainterName
          enabled: true
          name: sftpBlobInventoryName
          definition: {
            format: 'Csv'
            schedule: 'Daily'
            objectType: 'Blob'
            schemaFields: [
              'Name'
              'Creation-Time'
              'Last-Modified'
              'LastAccessTime'
              'Content-Length'
              'Content-MD5'
              'BlobType'
              'AccessTier'
              'AccessTierChangeTime'
              'AccessTierInferred'
              'Expiry-Time'
              'hdi_isfolder'
              'Owner'
              'Group'
              'Permissions'
              'Acl'
              'Snapshot'
              'Metadata'
            ]
            filters: {
              blobTypes: [
                'blockBlob'
              ]
              includeSnapshots: true
            }
          }
        }
      ]
    }
  }
}
*/
/*
resource sftpStgAcctAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: sftpStgAcctAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 30 // Delete logs after 30 days
    sku: {
      name: 'PerGB2018'
    }
  }
}
resource sftpStorageAccountAtpSettings 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
  name: 'current'
  scope: sftpStorageAccount
  properties: {
    isEnabled: true
  }
}
*/
