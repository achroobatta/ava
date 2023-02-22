@description('Location for all compute resources.')
param vmResouceGroupLocation string

@description('The name of your Virtual Machine.')
param vmName string

@description('Administrator username for the virtual machine')
param adminUsername string

@description('TimeZone')
param timeZone string

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
  // identity: {
  //   type: 'SystemAssigned'
  // }
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
    // diagnosticsProfile: {
    //   bootDiagnostics: {
    //     enabled: true
    //     storageUri: 'http://${diagstorageName}.blob.core.windows.net'
    //   }
    // }
  }
}

