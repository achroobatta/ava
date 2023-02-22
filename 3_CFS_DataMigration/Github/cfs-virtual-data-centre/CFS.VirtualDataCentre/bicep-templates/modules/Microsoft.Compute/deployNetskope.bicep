@description('The name of you Virtual Machine.')
param vmName string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Administrator password for the virtual machine')
@secure()
param adminPassword string

@description('Name of the storage account for boot diagnostics and VM diagnostics')
param diagstorageName string

@description('Determines the size of the default data disk in GB')
param OSDiskSize int

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

@description('Name of the subnet in the virtual network')
param subnetName string

var networkInterfaceName_var = 'nic-${vmName}-001'
var osDisk = '${vmName}-osDisk'

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
    enableAcceleratedNetworking: true
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
      adminPassword: adminPassword
      allowExtensionOperations: true
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
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
