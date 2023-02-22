@description('The name of you Virtual Machine.')
param vmName string

@description('Name of the storage account for boot diagnostics and VM diagnostics')
param diagstorageName string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Administrator password for the virtual machine')
@secure()
param adminPassword string

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


@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string


@description('Parameters for Image')
param ImageName string
param osDiskBlobUri string
param osAccountType string

@description('Determines the size of the default data disk in GB')
param OSDiskSize int

var osDisk = '${vmName}-osDisk'

@description('Datadisk object parameter')
param dataDisks object
 
@description('Name of the subnet in the virtual network')
param subnetName1 string

@description('Name of the subnet in the virtual network')
param subnetName2 string


param networkInterface array = [
  {
    networkInterfaceName: 'nic-${vmName}-001'
    subnetId: resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName1)
    primary: true
  }
  {
    networkInterfaceName: 'nic-${vmName}-002'
    subnetId: resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName2)
    primary: false
  }
]


resource dataDiskResources_name 'Microsoft.Compute/disks@2020-12-01' = [for (item,i) in dataDisks.value: if (!empty(dataDisks.value)) {
  name: '${vmName}-data-0${i+1}'
  location: vmResouceGroupLocation
  properties: item.properties
  sku: {
    name: item.sku
  }
}]


resource networkInterfaceNic 'Microsoft.Network/networkInterfaces@2020-06-01' = [for nic in networkInterface: {
  name: nic.networkInterfaceName
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
            id: nic.subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]



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
      dataDisks: [for (item,i) in dataDisks.value: {
        lun: item.lun
        createOption: item.createOption
        caching: item.caching
        diskSizeGB: item.diskSizeGB
        managedDisk: {
          id: (item.id ?? (('${vmName}-data-0${i+1}' == json('null')) ? json('null') : resourceId('Microsoft.Compute/disks', '${vmName}-data-0${i+1}')))
          storageAccountType: item.storageAccountType
        }
        deleteOption: item.deleteOption
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
      }]
      osDisk: {
        name: osDisk
        createOption: 'FromImage'
        diskSizeGB: OSDiskSize
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
          id: Image_resource.id
      }
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
    networkProfile: {
          networkInterfaces: [for nic in networkInterface: {
          id: resourceId('Microsoft.Network/networkInterfaces', nic.networkInterfaceName )
          properties: {
            primary: nic.primary
          }
     }]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'http://${diagstorageName}.blob.core.windows.net'
      }
    }
  }
}

resource Image_resource 'Microsoft.Compute/images@2019-07-01' = {
  name: ImageName
  location: vmResouceGroupLocation
  properties: {
    storageProfile: {
      osDisk: {
        diskSizeGB: 60
        osType: 'Linux'
        blobUri: osDiskBlobUri
        caching: 'ReadWrite'
        storageAccountType: osAccountType
        osState: 'Generalized'
      }
      dataDisks: []
      zoneResilient: false
    }
    hyperVGeneration: 'V1'
  }
  tags: {}
}
