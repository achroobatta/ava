@description('Location for all resources.')
param adfLocation string = resourceGroup().location

param identity string

param cfsname string 

param tags object

resource adfsymbolicnm 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: cfsname
  location: adfLocation
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity}': {}
    }
  } 
}


output adfid string = adfsymbolicnm.name
