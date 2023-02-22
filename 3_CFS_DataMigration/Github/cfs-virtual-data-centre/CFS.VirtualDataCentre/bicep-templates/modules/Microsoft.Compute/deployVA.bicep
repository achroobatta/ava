@description('The name of you Virtual Machine.')
param vmName string

@description('Name of the storage account for boot diagnostics and VM diagnostics')
param diagstorageName string

@description('Determines the size of the default data disk in GB')
param osDiskSize int

@description('Determines the storage type used for the OS disk')
param osDiskType string

@description('Location for all resources.')
param vmResouceGroupLocation string 

@description('Virtual Network Resource Group')
param vnetResourceGroup string

@description('The size of the VM')
param vmSize string

@description('Name of the VNET')
param virtualNetworkName string

@description('Managed disk ID')
param managedDiskID string


@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

@description('Name of the subnet in the virtual network')
param subnetName string

var osDiskName = '${vmName}-sailpoint-va'
var networkInterfaceName_var = 'nic-${vmName}-001'


resource networkInterfaceName 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: networkInterfaceName_var
  location: vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    Appliance: 'true'
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

resource vmName_resource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
    Appliance: 'true'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      dataDisks: []
      osDisk: {
        name: osDiskName
        osType: 'Linux'
        diskSizeGB: osDiskSize
        createOption: 'Attach'
        managedDisk: {
          storageAccountType: osDiskType
          id: managedDiskID
        }
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
