@description('The name of you Virtual Machine.')
param vmName string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('TimeZone')
param timeZone string

@description('Administrator password for the virtual machine')
@secure()
param adminPassword string

@description('Name of the storage account for boot diagnostics and VM diagnostics')
param diagstorageName string

@description('For Monitoring Agent')
param workspaceId string

@description('For Monitoring Agent')
param workspaceKey string

@description('for privateIPAllocationMethod')
param privateIPAllocationMethod string

@description('for Private IP Address')
param privateIPAddress string

@description('Determines the size of the default data disk in GB')
param OSDiskSize int

@description('Determines the storage type used for the OS disk')
param osDiskType string

@description('Datadisk object parameter')
param dataDisks object

@description('Location for all resources.')
param vmResouceGroupLocation string 

@description('Virtual Network Resource Group')
param vnetResourceGroup string

@description('The size of the VM')
param vmSize string

@description('Name of the VNET')
param virtualNetworkName string

@description('Enable Auto Shutdown? Yes or No')
param isEnableAutoShutdown bool

@description('Auto Shutdown Time of the day in 24 hours')
param autoShutdownTime string = '2100'

@description('The email recipient to send notifications to (can be a list of semi-colon separated email addresses)')
param autoShutdownNotificationEmail string

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
          privateIPAllocationMethod: privateIPAllocationMethod
          privateIPAddress: privateIPAddress
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

resource dataDiskResources_name 'Microsoft.Compute/disks@2020-12-01' = [for (item,i) in dataDisks.value: if (!empty(dataDisks.value)) {
  name: '${vmName}-data-0${i+1}'
  location: vmResouceGroupLocation
  properties: item.properties
  sku: {
    name: item.sku
  }
}]

resource vmName_microsoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: vmName_resource
  name: 'OmsAgentForLinux'
  location: vmResouceGroupLocation
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'OmsAgentForLinux'
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
  name: 'DependencyAgentLinux'
  location: vmResouceGroupLocation
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentLinux'
    typeHandlerVersion: '9.10'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

resource shutdown_computevm_virtualMachineName 'Microsoft.DevTestLab/schedules@2018-09-15' = if (isEnableAutoShutdown == true){
  name: 'shutdown-computevm-${vmName}'
  location: vmResouceGroupLocation
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: autoShutdownTime
    }
    timeZoneId: timeZone
    targetResourceId: vmName_resource.id
    notificationSettings: {
      status:'Enabled'
      timeInMinutes: 30
      emailRecipient: autoShutdownNotificationEmail
    }
  }
}
