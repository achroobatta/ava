@description('Location for all compute resources.')
param vmResouceGroupLocation string

@description('TimeZone')
param timeZone string

@description('The name of your Virtual Machine.')
param vmName string

@description('Administrator username for the virtual machine')
param adminUsername string

@description('Administrator password for the virtual machine')
@secure()
param adminPassword string

@description('Determines the storage type used for the OS disk')
param osDiskType string

@description('Determines the size of the default data disk in GB')
param OSDiskSize int

@description('The size of the VM - check Azure references for valid values')
param vmSize string

@description('Virtual Network Resource Group')
param vnetResourceGroup string

@description('Name of the existing virtual network')
param virtualNetworkName string

@description('Name of the subnet within the virtual network')
param subnetName string 

@description('Name of the storage account for boot diagnostics and VM diagnostics')
param diagstorageName string

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

@description('for privateIPAllocationMethod')
param privateIPAllocationMethod string

@description('for Private IP Address')
param privateIPAddress string

@description('for Image Reference')
param imageReferencePublisher string

@description('for Image Reference')
param imageReferenceOffer string

@description('for Image Reference')
param imageReferenceVersion string

@description('for Image Reference')
param imageSKU string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

var osDisk = '${vmName}-osDisk'
var networkInterfaceName_var = 'nic-${vmName}-001'

resource networkInterfaceName 'Microsoft.Network/networkInterfaces@2021-05-01' = {
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
          privateIPAllocationMethod: privateIPAllocationMethod
          privateIPAddress: privateIPAddress
        }
      }
    ]
  }
}

resource vmName_resource 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  location: vmResouceGroupLocation
  identity: {
    type: 'SystemAssigned'
  }
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
      imageReference: {
        publisher: imageReferencePublisher
        offer: imageReferenceOffer
        sku: imageSKU
        version: imageReferenceVersion
      }
      osDisk: {
        name: osDisk
        diskSizeGB: OSDiskSize
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        timeZone: timeZone
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'http://${diagstorageName}.blob.core.windows.net'
      }
    }
  }
}
resource vmName_Microsoft_Insights_VmDiagnosticsSettings 'Microsoft.Compute/virtualMachines/extensions@2021-07-01'= {
  parent: vmName_resource
  name: 'Microsoft.Insights.VmDiagnosticsSettings'
  location: vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
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
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
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
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
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
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
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

resource windowsVMGuestConfigExtension 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: vmName_resource
  name: 'AzurePolicyforWindows'
  location: vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}
