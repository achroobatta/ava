param backupPolicy object
param rsvName string


resource recoveryVaultName_policyName 'Microsoft.RecoveryServices/vaults/backupPolicies@2021-10-01' = {
  name: '${rsvName}/${backupPolicy.policyName}'
  location: resourceGroup().location
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRpRetentionRangeInDays: backupPolicy.instantRpRetentionRangeInDays
    schedulePolicy: {
      scheduleRunFrequency: 'Daily'
      scheduleRunDays: null
      scheduleRunTimes: backupPolicy.scheduleRunTimes
      schedulePolicyType: 'SimpleSchedulePolicy'
    }
    retentionPolicy: {
      dailySchedule: {
        retentionTimes: backupPolicy.scheduleRunTimes
        retentionDuration: {
          count: backupPolicy.dailyRetentionDurationCount
          durationType: 'Days'
        }
      }
      weeklySchedule: {
        daysOfTheWeek: backupPolicy.daysOfTheWeek
        retentionTimes: backupPolicy.scheduleRunTimes
        retentionDuration: {
          count: backupPolicy.weeklyRetentionDurationCount
          durationType: 'Weeks'
        }
      }
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
    timeZone: backupPolicy.timeZone
  }
}
