@description('Virtual Machine Name')
param vmName string

@description('Virtual Machine Resource Group Name')
param vmResouceGroupLocation string

@description('Virtual Machine Size')
param vmSize string

@description('Operating System / Image Preference')
param publisher string
param offer string
param sku string
param version string

var osDisk = '${vmName}-osDisk'
param osDiskSize int
param osDiskType string

var dataDisk = '${vmName}-data-01'
param dataDiskSize int
param dataDiskType string

@description('OS profile details')
param adminUsername string
@secure()
param adminPassword string
param perscode int

var networkInterfaceName_var = 'nic-${vmName}-001'
param vnetResourceGroup string
param virtualNetworkName string
param subnetName string
param privateIPAllocationMethod string
param privateIPAddress string

@description('Public IP yes/no.')
param isPublicIp bool = true

@description('Public IP true:new/false:existing.')
param isPublicIpNew bool = true
var publicIpName = 'pip-${vmName}-001'
var publicIpAllocationMethod = 'Static'
var publicIpSku = 'Standard'

@description('diagnosticsProfile details')
param diagstorageName string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

resource publicIpName_resource 'Microsoft.Network/publicIpAddresses@2019-11-01' = if (isPublicIp && isPublicIpNew) {
  name: publicIpName
  location: vmResouceGroupLocation
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
  sku: {
    name: publicIpSku
  }
}

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

resource vmName_resource 'Microsoft.Compute/virtualMachines@2019-12-01' = {
  name: vmName
  location: vmResouceGroupLocation
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: publisher
        offer: offer
        sku: sku
        version: version
      }
      osDisk: {
        name: osDisk
        diskSizeGB: osDiskSize
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      dataDisks: (dataDiskSize > 0) ? [ 
        {
          name: dataDisk
          diskSizeGB: dataDiskSize
          lun: 0
          managedDisk: {
            storageAccountType: dataDiskType
          }
          createOption: 'Empty'
        }
      ] : null
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
      customData: base64('PERSCODE=${perscode}')
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'http://${diagstorageName}.blob.core.windows.net'
      }
    }
  }
  plan: {
    name: sku
    publisher: publisher
    product: offer
  }
}
