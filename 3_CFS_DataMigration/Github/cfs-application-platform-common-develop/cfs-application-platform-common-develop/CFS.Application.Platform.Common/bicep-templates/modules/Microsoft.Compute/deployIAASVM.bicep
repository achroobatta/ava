@description('Location for all compute resources.')
param vmResouceGroupLocation string

@description('The name of your Virtual Machine.')
param vmName string

@description('Administrator password for the virtual machine')
@secure()
param clientSecret string

@description('Determines the storage type used for the OS disk')
param osDiskType string

@description('The size of the VM - check Azure references for valid values')
param vmSize string

@description('Virtual Network Resource Group')
param vnetResourceGroup string

@description('Name of the existing virtual network')
param virtualNetworkName string

@description('Name of the subnet within the virtual network')
param subnetName string 

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

@description('The admin user name of the VM')
param adminUsername string

@description('TimeZone')
param timeZone string

@description('Name of the storage account for boot diagnostics and VM diagnostics')
param diagstorageName string

@description('Same as the vmName')
param sqlVirtualMachineName string

@description('Amount of data disks (1TB each) for SQL Data files')
@minValue(1)
@maxValue(8)
param sqlDataDisksCount int

@description('Path for SQL Data files. Please choose drive letter from F to Z, and other drives from A to E are reserved for system')
param dataPath string

@description('Amount of data disks (1TB each) for SQL Log files')
@minValue(1)
@maxValue(8)
param sqlLogDisksCount int

@description('Path for SQL Log files. Please choose drive letter from F to Z and different than the one used for SQL data. Drive letter from A to E are reserved for system')
param logPath string

@description('Path for SQL tempdb files. Please choose drive letter from F to Z and different than the one used for SQL data. Drive letter from A to E are reserved for system')
param tempDbPath string

@description('Determines the size of the default data disk in GB')
param OSDiskSize int

@description('for Image Reference')
param imageReferencePublisher string

@description('for Image Reference')
param imageReferenceOffer string

@description('for Image Reference')
param imageReferenceVersion string

@description('for Image Reference')
param imageSKU string

@description('For Monitoring Agent')
param workspaceId string

@description('For Monitoring Agent')
param workspaceKey string

@description('For For Disk Encryption')
param keyVaultURL string

@description('For Disk Encryption')
param keyVaultName_resourceId string

@description('For Disk Encryption')
param KeyEncryptionKeyURL string

@description('For Disk Encryption')
param KekVaultResourceId string

@description('For ContainerName backup')
param containerName string

@description('For RGstorage_account backup')
param RGstorage_account string

@description('For storageAccountName backup')
param storageAccountName string

@description('Fo fullBackupStartTime backup')
param fullBackupStartTime int

@description('For fullBackupWindowHours')
param fullBackupWindowHours int

@description('for Domain Join Domain Name')
param domainName string

@description('for Domain Join Domain User Name')
param domainUserName string 

@description('for Domain Join Domain User Password')
param domainPassword string

@description('for Domain Join true or false')
param isEnableDomainJoin bool

@description('for Domain Join OUPath')
param OUPAth string

var networkInterfaceName_var = 'nic-${vmName}-001'
var osDisk = '${vmName}-osDisk'
var diskConfigurationType = 'NEW'

var dataDisks = {
  caching: 'ReadOnly'
  writeAcceleratorEnabled: false
  storageAccountType: 'Premium_LRS'
  dataDiskSize: 1023
}

resource storage_account 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
  scope: resourceGroup(RGstorage_account )
}



resource networkInterfaceName 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: networkInterfaceName_var
  location: vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vmName_resource 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  } 
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        name: osDisk
        diskSizeGB: OSDiskSize
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: imageReferencePublisher
        offer: imageReferenceOffer
        sku: imageSKU
        version: imageReferenceVersion
      }
      dataDisks: [for j in range(0, (sqlDataDisksCount + sqlLogDisksCount )): {
        lun: j
        createOption: 'Empty'
        caching: ((j >= sqlDataDisksCount) ? 'None' : dataDisks.caching)
        writeAcceleratorEnabled: dataDisks.writeAcceleratorEnabled
        diskSizeGB: dataDisks.dataDiskSize
        managedDisk: {
          storageAccountType: dataDisks.storageAccountType
        }
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: clientSecret
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        timeZone: timeZone
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'http://${diagstorageName}.blob.core.windows.net'
      }
    }
  }
}

resource sqlVirtualMachineName_resource 'Microsoft.SqlVirtualMachine/SqlVirtualMachines@2021-11-01-preview' = {
  name: sqlVirtualMachineName
  location: vmResouceGroupLocation
  properties: {
    virtualMachineResourceId: vmName_resource.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: diskConfigurationType
      storageWorkloadType: 'GENERAL'
      sqlDataSettings: {
        luns: [for j in range(0, sqlDataDisksCount): j ]
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: [for j in range(sqlDataDisksCount, sqlLogDisksCount): j ]
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        defaultFilePath: tempDbPath
      }
    }
    autoBackupSettings: {
      backupScheduleType: 'Manual'
      backupSystemDbs: true
      enable: true
      enableEncryption: false
      fullBackupFrequency: 'Daily'
      fullBackupStartTime: fullBackupStartTime
      fullBackupWindowHours: fullBackupWindowHours
      logBackupFrequency: 60
      retentionPeriod: 60
      storageAccessKey: storage_account.listKeys().keys[0].value
      storageAccountUrl: 'https://${storage_account.name}.blob.core.windows.net'
      storageContainerName: containerName
    } 
  }
}

resource vmName_Microsoft_Insights_VmDiagnosticsSettings 'Microsoft.Compute/virtualMachines/extensions@2021-07-01'  = {
  parent: vmName_resource
  name: 'Microsoft.Insights.VmDiagnosticsSettings'
  location: vmResouceGroupLocation
  properties: {
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'IaaSDiagnostics'
    typeHandlerVersion: '1.9'
    autoUpgradeMinorVersion: true
    settings: {
      WadCfg: {
        DiagnosticMonitorConfiguration: {
          overallQuotaInMB: 4096
          DiagnosticInfrastructureLogs: {
            scheduledTransferLogLevelFilter: 'Error'
          }
          Directories: {
            scheduledTransferPeriod: 'PT1M'
            IISLogs: {
              containerName: 'wad-iis-logfiles'
            }
            FailedRequestLogs: {
              containerName: 'wad-failedrequestlogs'
            }
          }
          PerformanceCounters: {
            scheduledTransferPeriod: 'PT1M'
            sinks: 'AzureMonitorSink'
            PerformanceCounterConfiguration: [
              {
                counterSpecifier: '\\Processor(_Total)\\% Processor Time'
                sampleRate: 'PT300S'
                unit: 'Percent'
                dislayName: 'CPU utilization'
              }
              {
                counterSpecifier: '\\System\\Processes'
                sampleRate: 'PT300S'
                unit: 'Count'
                dislayName: 'Processes'
              }
              {
                counterSpecifier: '\\Memory\\Available Bytes'
                sampleRate: 'PT300S'
                unit: 'Bytes'
                dislayName: 'Memory Available'
              }
              {
                counterSpecifier: '\\Memory\\% Committed Bytes In Use'
                sampleRate: 'PT300S'
                unit: 'Percent'
                dislayName: 'Memory Usage'
              }
              {
                counterSpecifier: '\\Memory\\Committed Bytes'
                sampleRate: 'PT300S'
                unit: 'Bytes'
                dislayName: 'Memory Committed'
              }
              {
                counterSpecifier: '\\LogicalDisk(_Total)\\% Free Space'
                sampleRate: 'PT900S'
                unit: 'Percent'
                dislayName: 'Disk free space (percentage)'
              }
              {
                counterSpecifier: '\\PhysicalDisk(_Total)\\% Disk Read Time'
                sampleRate: 'PT900S'
                unit: 'Percent'
                dislayName: 'Disk active read time'
              }
              {
                counterSpecifier: '\\PhysicalDisk(_Total)\\% Disk Write Time'
                sampleRate: 'PT900S'
                unit: 'Percent'
                dislayName: 'Disk active write time'
              }
            ]
          }
          WindowsEventLog: {
            scheduledTransferPeriod: 'PT1M'
            DataSource: [
              {
                name: 'Application!*'
              }
              {
                name: 'Security!*'
              }
              {
                name: 'System!*'
              }
            ]
          }
          Logs: {
            scheduledTransferPeriod: 'PT1M'
            scheduledTransferLogLevelFilter: 'Error'
          }
        }
        SinksConfig: {
          Sink: [
            {
              name: 'AzureMonitorSink'
              AzureMonitor: {}
            }
          ]
        }
      }
      StorageAccount: diagstorageName
    }
  protectedSettings: {
    storageAccountName: diagstorageName
    storageAccountEndPoint: 'https://blob.core.windows.net/'
  }
} 
}

resource vmName_microsoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: vmName_resource
  name: 'microsoftMonitoringAgent'
  location: vmResouceGroupLocation
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: workspaceId
    }
    protectedSettings: {
      workspaceKey: workspaceKey
    }
  }
}

resource vmName_DAExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: vmName_resource
  name: 'DAExtension'
  location: vmResouceGroupLocation
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}
resource vmName_diskEncryption 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: vmName_resource
  name: 'AzureDiskEncryption'
  location: vmResouceGroupLocation
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'AzureDiskEncryption'
    typeHandlerVersion: '2.2'
    autoUpgradeMinorVersion: true
    settings: {
      EncryptionOperation: 'EnableEncryption'
      KeyVaultURL: keyVaultURL
      KeyVaultResourceId: keyVaultName_resourceId
      KeyEncryptionKeyURL: KeyEncryptionKeyURL
      KeyEncryptionAlgorithm: 'RSA-OAEP'
      KekVaultResourceId: KekVaultResourceId
      VolumeType: 'All'
    }
  }
}

resource joindomain 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = if (isEnableDomainJoin == true) {
  name: '${vmName}/domainjoin'
  location: vmResouceGroupLocation
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: domainName
      OUPath: OUPAth
      User: domainUserName
      Restart: 'true'
      Options: '3'
    }
    protectedSettings: {
      Password: domainPassword
    }
  }
  dependsOn: [
    vmName_resource
    sqlVirtualMachineName_resource
  ]
}

output adminUsername string = adminUsername

