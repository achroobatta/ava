param hpName string

param location string

@description('Tags')
param appName string
param costCenter string
param environment string
param owner string
param createOnDate string

@description('Hosting Pool Parameters')
@allowed([
'Personal'
'Pooled'
])
param hpHostPoolType string

@allowed([
  'Desktop'
  'RailApplications'
  ])
param hpAppGroupType string
param hpDescription string
@allowed([
'BreadthFirst'
'DepthFirst'
'Persistent'
])
param hpLoadBalancerType string
param hpMaxSessionLimit int

@allowed([
'Automatic'
'Direct'
])
param hpDesktopAssignmentType string

@description('Application Group Parameters')
param agDescription string
param agFriendlyName string
param agAppGroupType string

@description('Workspaces Parameters')
param wsName string
param wsFriendlyName string
param wsDescription string

param logAnalyticsWorkspaceSubId string
param logAnalyticsWorkspaceRg string
param logAnalyticsWorkspaceNm string

var workspaceId = resourceId(logAnalyticsWorkspaceSubId, logAnalyticsWorkspaceRg, 'Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceNm)
param rdpProperties string

// Deploy Hosting Pool Resource
resource hostingPoolresource 'Microsoft.DesktopVirtualization/hostPools@2022-09-09' = {
  name: hpName
  location: location
  tags: {
    appName: appName
    costCenter: costCenter
    environment: environment
    owner: owner
    createOnDate: createOnDate
  }
  properties: {
    preferredAppGroupType: hpAppGroupType
    description: hpDescription
    hostPoolType: hpHostPoolType
    personalDesktopAssignmentType: hpDesktopAssignmentType
    loadBalancerType: hpLoadBalancerType
    maxSessionLimit: hpMaxSessionLimit
    customRdpProperty: rdpProperties
  }
}

//Deploying Application Group
resource appGroupresource 'Microsoft.DesktopVirtualization/applicationGroups@2022-09-09' = {
  name: '${hpName}-DAG'
  location: location
  tags: {
    appName: appName
    costCenter: costCenter
    environment: environment
    owner: owner
    createOnDate: createOnDate
  }
  properties: {
    applicationGroupType: agAppGroupType
    hostPoolArmPath: hostingPoolresource.id
    description: agDescription
    friendlyName: agFriendlyName
  }
}

//Deploying Workspace
resource workspaceresource 'Microsoft.DesktopVirtualization/workspaces@2022-09-09' = {
  name: wsName
  location: location
  tags: {
    appName: appName
    costCenter: costCenter
    environment: environment
    owner: owner
    createOnDate: createOnDate
  }
  properties: {
    applicationGroupReferences: [
      appGroupresource.id
    ]
    description: wsDescription
    friendlyName: wsFriendlyName
  }
}

resource hpInsights 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'WVDInsights'
  scope: hostingPoolresource
  properties: {
    logs: [
      {
        category: 'Checkpoint'
        enabled: true
      }
      {
        category: 'Error'
        enabled: true
      }
      {
        category: 'Management'
        enabled: true
      }
      {
        category: 'Connection'
        enabled: true
      }
      {
        category: 'HostRegistration'
        enabled: true
      }
      {
        category: 'AgentHealthStatus'
        enabled: true
      }
    ]
    workspaceId: workspaceId
  }
}

resource wsInsights 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'WVDInsights'
  scope: workspaceresource
  properties: {
    logs: [
      {
        category: 'Checkpoint'
        enabled: true
      }
      {
        category: 'Error'
        enabled: true
      }
      {
        category: 'Management'
        enabled: true
      }
      {
        category: 'Feed'
        enabled: true
      }
    ]
    workspaceId: workspaceId
  }
}
