@description('The name of the VM')
param vmName string

@description('The virtual machine size.')
param vmSize string

@description('Location for all resources.')
param vmResouceGroupLocation string

@description('Virtual Network Resource Group')
param vnetResourceGroup string

@description('Name of the subnet within the virtual network')
param subnetName string 

@description('Name of the existing virtual network')
param virtualNetworkName string

@description('Determines the storage type used for the OS disk')
param osDiskType string

@description('The admin user name of the VM')
param adminUsername string

@description('The admin password of the VM')
@secure()
param clientSecret string

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

@description('This will be used as a tag')
param resourceTags object

@description('Determines the size of the default data disk in GB')
param OSDiskSize int

var networkInterfaceName_var = 'nic-${vmName}-001'
var osDisk = '${vmName}-osDisk'
var diskConfigurationType = 'NEW'
var dataDisksLuns = array(range(0, sqlDataDisksCount))
var logDisksLuns = array(range(sqlDataDisksCount, sqlLogDisksCount))
var dataDisks = {
  caching: 'ReadOnly'
  writeAcceleratorEnabled: false
  storageAccountType: 'Premium_LRS'
  dataDiskSize: 1023
}

resource networkInterfaceName 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: networkInterfaceName_var
  location: vmResouceGroupLocation
  tags: resourceTags
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
    enableAcceleratedNetworking: true
  }
}

resource virtualMachine_resource 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: vmResouceGroupLocation
  tags: resourceTags
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
        publisher: 'MicrosoftSQLServer'
        offer: 'sql2019-ws2019'
        sku: 'Standard'
        version: 'latest'
      }
      dataDisks: [for j in range(0, (sqlDataDisksCount + sqlLogDisksCount)): {
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

resource Microsoft_SqlVirtualMachine_SqlVirtualMachines_virtualMachine 'Microsoft.SqlVirtualMachine/SqlVirtualMachines@2017-03-01-preview' = {
  name: sqlVirtualMachineName
  location: vmResouceGroupLocation
  tags: resourceTags
  properties: {
    virtualMachineResourceId: virtualMachine_resource.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    storageConfigurationSettings: {
      diskConfigurationType: diskConfigurationType
      storageWorkloadType: 'GENERAL'
      sqlDataSettings: {
        luns: dataDisksLuns
        defaultFilePath: dataPath
      }
      sqlLogSettings: {
        luns: logDisksLuns
        defaultFilePath: logPath
      }
      sqlTempDbSettings: {
        defaultFilePath: tempDbPath
      }
    }
  }
}

output adminUsername string = adminUsername
