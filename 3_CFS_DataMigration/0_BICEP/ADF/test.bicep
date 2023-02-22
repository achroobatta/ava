targetScope = 'resourceGroup'

var shirAdfIr = 'shirIR'
var shirAdf = 'cfskxkAdf'
var vmname = 'cfskxkShirPc'
var miname = 'cfskxkIdentity'
var storageAccountName = 'cfskxkz57ostg01'
var location = resourceGroup().location

resource shirmain 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' existing = {
  name: shirAdfIr
}

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: miname 
}
var shirName = shirmain.name
var keysObj = listAuthKeys(resourceId('Microsoft.DataFactory/factories/integrationRuntimes', shirAdf, shirName),'2018-06-01')
var key1 = keysObj.authKey1

var identity = mi.properties.clientId
var path = 'C:\\Users\\demousr\\Downloads\\IntegrationRuntime_5.22.8312.1.msi'
var commandToExecute = 'powershell -ExecutionPolicy Unrestricted -File InstallGatewayOnLocalMachine.ps1 -Path ${path} -authKey ${key1}'

resource vm_customScriptExtensions 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {  
  name: '${vmname}/cfsshirextension'
  location: location

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
      fileUris: ['https://${storageAccountName}.blob.core.windows.net/data/InstallGatewayOnLocalMachine.ps1']
      commandToExecute: commandToExecute      
      managedIdentity : {        
        clientId: identity
       }        
    }             
  }
}
