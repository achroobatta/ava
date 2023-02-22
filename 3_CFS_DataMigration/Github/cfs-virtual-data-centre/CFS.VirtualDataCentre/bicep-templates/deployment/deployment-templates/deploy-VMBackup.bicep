targetScope = 'subscription'

param resourceGroupObject object
param environmentPrefix string
var environmentUpper = toUpper(environmentPrefix)

module vmBackup '../../modules/Microsoft.RecoveryServices/vaults/deployVMBackup.bicep' = [for (rg, i) in resourceGroupObject.resourceGroups: {
  name: 'vmbackup-${i}'
  scope: resourceGroup('rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.component}-00${rg.rsvinstance}')
  params: {
    recoveryVaultName: 'rsv-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.service}-00${rg.rsvinstance}'
    vmResourceGroup: 'rg-${environmentPrefix}-${(rg.location == 'australiaeast') ? 'edc' : 'sdc' }-${rg.serviceAbbrv}-${rg.vmRGcomponent}-00${rg.vmRGinstance}'
    environmentPrefix: environmentUpper
    location: '${(rg.location == 'australiaeast') ? 'EDC' : 'SDC' }'
    vmName: rg
  }
}]
