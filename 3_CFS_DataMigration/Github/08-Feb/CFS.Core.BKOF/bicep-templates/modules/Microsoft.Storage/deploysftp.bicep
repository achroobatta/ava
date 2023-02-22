param sftplocation string = resourceGroup().location

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string
param deleteByDate string

param sftpstorageAccountName string
param sftpRootContainerName string
// param sftpUserName string
// @secure()
// param sshKeyName string

param virtualNetworkResourceGroup string
param virtualNetworkName_RG string
param virtualNetworksubnetName string

param performance string
param kind string
param publicNetworkAccess string
param minimumTlsVersion string
param allowBlobPublicAccess bool
param supportsHttpsTrafficOnly bool
param allowSharedKeyAccess bool
param isHnsEnabled bool
param isSftpEnabled bool
param largeFileSharesState string
param isNfsV3Enabled bool

// @description('UTC timestamp used to create distinct deployment scripts for each deployment')
// param utcValue string = utcNow()

// var filename = 'sftpdummy.txt'

//param sftpBlobInventoryName string
//param sftpmanagementPolicyName string
//param sftpStgAcctAnalyticsWorkspaceName string

//param vnetSubnetResourceId string
// param sftpWhiteListip string

// param vnetSubnetResourceIds array = [
//   'resourceId(${virtualNetworkResourceGroup}, \'Microsoft.Network/virtualNetworks/subnets\', ${virtualNetworkName_RG}, ${virtualNetworksubnetName})'
//   'subscriptionResourceId(\'subsc-np-operations-001', 'Microsoft.Network/virtualNetworks/subnets', 'rg-np-edc-oper-netw-001', 'sub-np-edc-operations-001\')'
//   'subscriptionResourceId(\'subsc-np-operations-001', 'Microsoft.Network/virtualNetworks/subnets', 'rg-np-edc-oper-netw-001', 'sub-np-edc-operations-002\')'
//   'subscriptionResourceId(\'subsc-np-operations-001', 'Microsoft.Network/virtualNetworks/subnets', 'rg-np-sdc-oper-netw-001', 'sub-np-sdc-operations-001\')'
//   'subscriptionResourceId(\'subsc-np-operations-001', 'Microsoft.Network/virtualNetworks/subnets', 'rg-np-sdc-oper-netw-001', 'sub-np-sdc-operations-002\')'
// ]
// @description('An array of IPv4 addresses to be whitelisted for access to this SFTP storage account and container. Do not specify RFC 1918 addresses nor CIDRs smaller than /30. This should be a list of the IPs representing machines at the other end of the SFTP transfer.')
// param sftpWhiteListedIps array
// param ipRulesaction string
param virtualNetworkRulesaction string
param defaultAction string
// = [
//   '1.157.208.55'
// ]

// resource sshkeyName 'Microsoft.Compute/sshPublicKeys@2022-08-01' existing = {
//    name: sshKeyName
// }

resource sftpStorageAccountNameArray 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: sftpstorageAccountName
  location: sftplocation
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
      defaultAction: defaultAction
      // /*
      // virtualNetworkRules: [for vnetSubnetResourceId in vnetSubnetResourceIds: {
      //   id: vnetSubnetResourceId
      //   action: 'Allow'
      // }]
      // ipRules: [for sftpWhiteListip in sftpWhiteListedIps: {
      //   value: sftpWhiteListip
      //   action: ipRulesaction
      // }]
      virtualNetworkRules: [{
        id: resourceId(virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName_RG, virtualNetworksubnetName)            
        action: virtualNetworkRulesaction
      }]
    //   ipRules: [
    //     {
    //     value: sftpWhiteListip
    //     action: 'Allow'
    //   }
    // ]
    }
    publicNetworkAccess: publicNetworkAccess
    minimumTlsVersion: minimumTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowSharedKeyAccess: allowSharedKeyAccess
    isHnsEnabled: isHnsEnabled
    isSftpEnabled: isSftpEnabled
    largeFileSharesState: largeFileSharesState
    isNfsV3Enabled: isNfsV3Enabled
  }
}

resource sftpStorageBlobArray 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: sftpStorageAccountNameArray
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

resource sftpStorageContainerArray 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  parent: sftpStorageBlobArray
  name: sftpRootContainerName
}

// resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   name: 'deployscript-upload-file-${utcValue}'
//   location: sftplocation
//   kind: 'AzureCLI'
//   properties: {
//     azCliVersion: '2.26.1'
//     timeout: 'PT5M'
//     retentionInterval: 'PT1H'
//     environmentVariables: [
//       {
//         name: 'AZURE_STORAGE_ACCOUNT'
//         value: sftpStorageAccountNameArray.name
//       }
//       {
//         name: 'AZURE_STORAGE_KEY'
//         value: sftpStorageAccountNameArray.listKeys().keys[0].value
//       }
//       {
//         name: 'CONTENT'
//         value: loadTextContent('sftpdummy.txt')
//       }
//     ]
//     scriptContent: 'echo "$CONTENT" > ${filename}  && az storage blob upload --account-name ${sftpStorageAccountNameArray.name} --account-key ${sftpStorageAccountNameArray.listKeys().keys[0].value} -c ${sftpStorageContainerArray.name} --file ${filename} -n ${filename}'
//   }
// }

// resource sftpLocalUser 'Microsoft.Storage/storageAccounts/localUsers@2021-09-01' = {
//   name: sftpUserName
//   parent: sftpStorageAccountNameArray
//   properties: {
//     permissionScopes: [
//       {
//         permissions: 'rl'
//         service: 'blob'
//         resourceName: sftpRootContainerName
//       }
//     ]
//     homeDirectory: sftpRootContainerName
//     hasSshPassword: false

//     sshAuthorizedKeys: [
//       {
//         description: 'SSH public key to authenticate with a connection originative from either sftpWhiteListedIps or VnetSubnetResourceIds'
//         // key: sshkeyName.properties.publicKey
//         key: sshKeyName

//       }
//     ]
//     hasSharedKey: false
//   }
// }


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
