
@description('location')
param location string = resourceGroup().location

param shirPcName string 

@description('storage Account ')
param storageAccountName string

@description('Name of shir Adf')
param shirAdf string

@description('Name of shirIR')
param shirAdfIr string

@description('clientId of management Identity')
param identity string

@description('tags of the project')
param tags object

var shirName = shirAdfIr
var keysObj = listAuthKeys(resourceId('Microsoft.DataFactory/factories/integrationRuntimes', shirAdf, shirName),'2018-06-01')
var key1 = keysObj.authKey1

var file = 'C:\\Users\\demousr\\Downloads\\InstallGatewayOnLocalMachine.ps1'
var path = 'C:\\Users\\demousr\\Downloads\\IntegrationRuntime_5.22.8312.1.msi'
var commandToExecute = 'powershell -ExecutionPolicy Unrestricted -File ${file} -Path ${path} -authKey ${key1}'           

resource vm_customScriptExtensions 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {  
  name: '${shirPcName}/cfsshirextension'
  location: location
  tags: tags 
  properties: {    
    autoUpgradeMinorVersion: true
    typeHandlerVersion: '1.10'    
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    forceUpdateTag: 'true'    
    settings: {
      timestamp: 123456789
    }
    protectedSettings: {
      // fileUris: ['https://${storageAccountName}.blob.core.windows.net/data/InstallGatewayOnLocalMachine.ps1']
      commandToExecute: commandToExecute
      managedIdentity : {        
        clientId: identity
       }        
    }             
  }
}
