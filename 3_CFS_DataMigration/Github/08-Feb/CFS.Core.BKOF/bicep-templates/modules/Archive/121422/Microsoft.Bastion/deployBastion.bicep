@description('Name of new or existing vnet to which Azure Bastion should be deployed')
param vnet_name string

@description('Bastion subnet IP prefix MUST be within vnet IP prefix address space')
param bastion_subnet_ip_prefix string

@description('Name of Azure Bastion resource')
param bastion_host_name string

@description('Azure region for Bastion and virtual network')
param location string

@description('Set tag for Runtime Environment')
param resourceTags object

var publicipaddressnamevar = '${bastion_host_name}-pip'
var bastion_subnet_name = 'AzureBastionSubnet'

resource public_ip_address_name 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: publicipaddressnamevar
  location: location
  sku: {
    name: 'Standard'
  }
  tags: resourceTags
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vnet_name_bastion_subnet_name 'Microsoft.Network/virtualNetworks/subnets@2019-02-01' = {
  name: '${vnet_name}/${bastion_subnet_name}'
  properties: {
    addressPrefix: bastion_subnet_ip_prefix
  }
}

resource bastion_host_name_resource 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: bastion_host_name
  location: location
  tags: resourceTags
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: vnet_name_bastion_subnet_name.id
          }
          publicIPAddress: {
            id: public_ip_address_name.id
          }
        }
      }
    ]
  }
}
