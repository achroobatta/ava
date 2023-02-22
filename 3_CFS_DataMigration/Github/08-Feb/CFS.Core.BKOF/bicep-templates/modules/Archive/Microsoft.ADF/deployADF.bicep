@description('Data Factory Name')
param dataFactoryName string

@description('Location of the data factory.')
param location string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

var shirName = 'shirAgent'

resource dataFactoryName_resource 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }   
  properties:{
    publicNetworkAccess:'Disabled'   
  }

}

resource shir_resource 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: shirName
  parent: dataFactoryName_resource 
  properties: {
    description: 'Self Hosted Integration Runtime'
    type: 'SelfHosted'   
  }
}

output adfresourceID string = dataFactoryName_resource.id
