@description('Scaling plan parameters')
param spName string
param location string

@description('Tags parameters')
param appName string
param costCenter string
param environment string
param owner string
param createOnDate string

param spDescription string
param spExclusionTag string
param spFriendlyName string
param hpPoolType string
param timeZone string
param hpNamesforAssignment array
param schedulingObj array

resource hostingPoolresource 'Microsoft.DesktopVirtualization/hostPools@2022-09-09' existing = [ for hp in hpNamesforAssignment: {
  name: hp.hpName
  scope: resourceGroup(hp.hpRgName)
}]

resource scalingPlanResource 'Microsoft.DesktopVirtualization/scalingPlans@2022-09-09' = {
  name: spName
  location: location
  tags: {
    appName: appName
    costCenter: costCenter
    environment: environment
    owner: owner
    createOnDate: createOnDate
  }
  properties: {
    description: spDescription
    exclusionTag: spExclusionTag
    friendlyName: spFriendlyName
    hostPoolType: hpPoolType
    timeZone: timeZone
    hostPoolReferences: [for (hp, i) in  hpNamesforAssignment :  {
        hostPoolArmPath: hostingPoolresource[i].id
        scalingPlanEnabled: true
      }]
    schedules: [ for schd in schedulingObj : {
        daysOfWeek: schd.daysOfWeek
        name: schd.name
        offPeakLoadBalancingAlgorithm: schd.offPeakLoadBalancingAlgorithm
        offPeakStartTime: schd.offPeakStartTime
        peakLoadBalancingAlgorithm: schd.peakLoadBalancingAlgorithm
        peakStartTime: schd.peakStartTime
        rampDownCapacityThresholdPct: schd.rampDownCapacityThresholdPct
        rampDownForceLogoffUsers: true
        rampDownLoadBalancingAlgorithm: schd.rampDownLoadBalancingAlgorithm
        rampDownMinimumHostsPct: schd.rampDownMinimumHostsPct
        rampDownNotificationMessage: schd.rampDownNotificationMessage
        rampDownStartTime: schd.rampDownStartTime
        rampDownStopHostsWhen:schd.rampDownStopHostsWhen
        rampDownWaitTimeMinutes: schd.rampDownWaitTimeMinutes
        rampUpCapacityThresholdPct: schd.rampUpCapacityThresholdPct
        rampUpLoadBalancingAlgorithm: schd.rampUpLoadBalancingAlgorithm
        rampUpMinimumHostsPct: schd.rampUpMinimumHostsPct
        rampUpStartTime: schd.rampUpStartTime
      }]
  }
}
