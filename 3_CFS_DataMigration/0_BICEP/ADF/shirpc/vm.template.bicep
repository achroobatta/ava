
@description('')
param shirPcName string
var networkInterfaceName = '${shirPcName}-Iface'
var virtualMachineName  = shirPcName

@description('')
param osDiskType string = 'Premium_LRS'
@description('')
param virtualMachineSize string = 'Standard_D2s_v3'
// @description('')
// param patchMode string = 'AutomaticByOS'
@description('')
param vnetName string
// @description('')
// param adminUsername string
@description('')
param location string = resourceGroup().location
// @description('')
// @secure()
// param adminPassword string
@description('subscriptionId of your tenant')
param subscriptionId string

// @description('Required. The name of the extension handler publisher.')
// param publisher string = 'MicrosoftWindowsServer'

param identity string

param tags object

@description('Image Gallery Properties')
param galleryRG string = 'imageRG'
param version string = '0.0.1'
param image string = 'image'
param galleryNm string = 'imageGallery'


var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'public-subnet')


resource pip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${shirPcName}pubIP'
  location: location
  tags: tags 
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    deleteOption: 'Detach'
    idleTimeoutInMinutes: 15
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource networkInterfaceName_resource 'Microsoft.Network/networkInterfaces@2018-10-01' = {
  name: networkInterfaceName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    
  }
}

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: virtualMachineName
  tags: tags
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity}': {}
    }
  }
  properties: {
  
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      // imageReference: {
      //   publisher: publisher
      //   offer: 'WindowsServer'
      //   sku: '2019-Datacenter'
      //   version: 'latest'
      // }
        imageReference: {
          // publisher: 'demo'
          // offer: 'demo'
          // sku: 'demo'
          // version: '0.0.1'        
          id:  '/subscriptions/${subscriptionId}/resourceGroups/${galleryRG}/providers/Microsoft.Compute/galleries/${galleryNm}/images/${image}/versions/${version}'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName_resource.id
        }
      ]
    }
    // osProfile: {
    //   computerName: virtualMachineName
    //   adminUsername: adminUsername
    //   adminPassword: adminPassword
    //   windowsConfiguration: {
    //     enableAutomaticUpdates: true
    //     provisionVMAgent: true
    //     patchSettings: {
    //       enableHotpatching: false
    //       patchMode: patchMode
    //     }
    //   }
    // }
    licenseType: 'Windows_Server'
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  } 
}



// output adminUsername string = adminUsername
output shirPrivateIpaddr string = reference(resourceId('Microsoft.Network/networkInterfaces', networkInterfaceName)).ipConfigurations[0].properties.privateIPAddress
output shirPCName string = virtualMachineName_resource.name
