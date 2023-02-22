@description('Location for all compute resources.')
param vmResouceGroupLocation string

@description('The name of your Virtual Machine.')
param shirVmName string

@description('Administrator username for the virtual machine')
param adminUsername string

@description('Data Factory Name')
param dataFactoryName string

//name of the SHIR Agent
var shirName = 'shirAgent'

@description('clientId of management Identity')
param identity string

@description('TimeZone')
param timeZone string

@description('Parameters for resource tags')
param appName string
param environmentPrefix string
param owner string
param costCenter string
param createOnDate string

var keysObj = listAuthKeys(resourceId('Microsoft.DataFactory/factories/integrationRuntimes', dataFactoryName, shirName),'2018-06-01')
var key1 = keysObj.authKey1

var file = 'C:\\Users\\${adminUsername}\\Downloads\\InstallGatewayOnLocalMachine.ps1'
var path = 'C:\\Users\\${adminUsername}\\Downloads\\IntegrationRuntime_5.22.8312.1.msi'
var commandToExecute = 'powershell -ExecutionPolicy Unrestricted -File ${file} -Path ${path} -authKey ${key1}'           

resource vm_customScriptExtensions 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {  
  name: '${shirVmName}/cfsshirextension'
  location: vmResouceGroupLocation
  tags: {
    appName: appName
    environment: environmentPrefix
    owner: owner
    costCenter: costCenter
    createOnDate: createOnDate
  }
  properties: {    
    autoUpgradeMinorVersion: true
    typeHandlerVersion: '1.10'    
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    forceUpdateTag: 'true'    
    settings: {
      timestamp: timeZone
    }
    protectedSettings: {      
      commandToExecute: commandToExecute
      managedIdentity : {        
        clientId: identity
       }        
    }             
  }
}
