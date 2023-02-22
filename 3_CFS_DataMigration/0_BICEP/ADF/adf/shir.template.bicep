@description('Name of the ADF passed during module call')
param parentname string

param shirname string

resource shirsymbolicname 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: '${parentname}/${shirname}'  
  properties: {
    description: 'Self Hosted Integration Runtime'
    type: 'SelfHosted'
  
  }
}


output shirId string = shirsymbolicname.id

