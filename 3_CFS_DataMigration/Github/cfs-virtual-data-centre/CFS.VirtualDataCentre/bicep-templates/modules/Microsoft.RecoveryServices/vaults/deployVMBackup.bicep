@description('The name of the existing recovery vault resource')
param recoveryVaultName string

@description('The name of the recovery vault resource')
param policyName string = 'VMBackup'

@description('The resource group of the target VM')
param vmResourceGroup string

@description('Name of the Azure virtual machine that will be backed up')
param vmName object
param environmentPrefix string
param location string


resource recoveryVaultName_Azure_protectionContainer_protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-10-01' = [for rg in vmName.vmBackup: {
  name: '${recoveryVaultName}/Azure/IaasVMContainer;iaasvmcontainerv2;${vmResourceGroup};VM${environmentPrefix}${location}${rg.vmName}/vm;iaasvmcontainerv2;${vmResourceGroup};VM${environmentPrefix}${location}${rg.vmName}'
  location: resourceGroup().location
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: resourceId('Microsoft.RecoveryServices/vaults/backupPolicies', recoveryVaultName, policyName)
    sourceResourceId: resourceId(vmResourceGroup, 'Microsoft.Compute/virtualMachines', 'VM${environmentPrefix}${location}${rg.vmName}')
  }
}]
