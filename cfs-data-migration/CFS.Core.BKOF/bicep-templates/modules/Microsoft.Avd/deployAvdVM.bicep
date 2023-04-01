// -- Common VM Details
@description('Location for all compute resources.')
param vmResouceGroupLocation string

@description('The name of your Virtual Machine.')
param vmName string

// -- TAGS Parameters
@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string


// -- Network Interface Parameters
@description('Virtual Network Resource Group')
param vnetResourceGroup string

@description('Name of the existing virtual network')
param virtualNetworkName string

@description('Name of the subnet within the virtual network')
param subnetName string

@description('for privateIPAllocationMethod')
param privateIPAllocationMethod string

@description('for Private IP Address')
param privateIPAddress string


//-- Data Disks Parameters
param dataDisksCount int

@description('Datadisk object parameter')
param dataDisks object

//-- VM Parameters

@description('availability set name')
param availabilitySetName string

@description('The size of the VM - check Azure references for valid values')
param vmSize string

@description('for Image Reference')
param imageReferencePublisher string

@description('for Image Reference')
param imageReferenceOffer string

@description('for Image Reference')
param imageSKU string

@description('for Image Reference')
param imageReferenceVersion string

@description('Determines the size of the default data disk in GB')
param OSDiskSize int

@description('Determines the storage type used for the OS disk')
param osDiskType string

@description('Administrator username for the virtual machine')
param adminUsername string

@description('Administrator password for the virtual machine')
@secure()
param adminPassword string

@description('TimeZone')
param timeZone string


// -- Monitoring Agent Parameters
@description('For Monitoring Agent')
param workspaceId string

@description('For Monitoring Agent')
param workspaceKey string

// -- Domain Join

@description('for Domain Join true or false')
param isEnableDomainJoin bool

@description('for Domain Join Domain Name')
param domainName string

@description('for Domain Join OUPath')
param OUPAth string

@description('for Domain Join Domain User Name')
param domainUserName string

@description('for Domain Join Domain User Password')
@secure()
param domainPassword string

// -- PowerShell DSC Parameters
param hostPoolName string
param aadJoin bool
param hpRg string
param registrationKey string
param configUrl string

var osDisk = '${vmName}-osDisk'
var networkInterfaceName_var = '${vmName}-nic'

// -- VM Shutdown
param isEnableAutoShutdown bool
@description('Auto Shutdown Time of the day in 24 hours')
param autoShutdownTime string = '2100'
@description('The email recipient to send notifications to (can be a list of semi-colon separated email addresses)')
param autoShutdownNotificationEmail string


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
        name: 'ipconfig'
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

resource dataDiskResources_name 'Microsoft.Compute/disks@2020-12-01' = [for i in range(0, dataDisksCount): {
  name: '${vmName}-data-0${i+1}'
  location: vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: dataDisks.properties
  sku: {
    name: dataDisks.sku
  }
}]

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
    availabilitySet: !empty(availabilitySetName) ? {
      id: resourceId('Microsoft.Compute/availabilitySets', availabilitySetName)
    } : null
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
        deleteOption: 'Delete'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }

    dataDisks: [for i in range(0, dataDisksCount): {
      lun: i
      createOption: dataDisks.createOption
      caching: dataDisks.caching
      diskSizeGB: dataDisks.diskSizeGB
      managedDisk: {
        id: (dataDisks.id ?? (('${vmName}-data-0${i+1}' == json('null')) ? json('null') : resourceId('Microsoft.Compute/disks', '${vmName}-data-0${i+1}')))
        storageAccountType: dataDisks.storageAccountType
      }
      deleteOption: dataDisks.deleteOption
      writeAcceleratorEnabled: dataDisks.writeAcceleratorEnabled
    }]
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
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
  dependsOn: [
    dataDiskResources_name
  ]
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
  // dependsOn: [
  //   vmName_resource
  // ]
}

resource vmName_microsoftMonitoringAgent 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  parent: vmName_resource
  name: 'MicrosoftMonitoringAgent'
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


resource joindomain 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = if (isEnableDomainJoin == true) {
  name: '${vmName}/joindomain'
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
    shutdown_computevm_virtualMachineName
  ]
}

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2022-09-09' existing = {
  name: hostPoolName
  scope: resourceGroup(hpRg)
}

//need to add PowerShellDSC configuration extension
resource sessionHostAVDAgent 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' =  {
  name: '${vmName}/Microsoft.PowerShell.DSC'
  location: vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.73'
    autoUpgradeMinorVersion: true
    settings: {
      modulesUrl: configUrl
      configurationFunction: 'Configuration.ps1\\AddSessionHost'
      properties: {
        hostPoolName: hostPool.name
        registrationInfoToken: registrationKey
        aadJoin: aadJoin
      }
    }
  }

  dependsOn: [
    joindomain
  ]
}
