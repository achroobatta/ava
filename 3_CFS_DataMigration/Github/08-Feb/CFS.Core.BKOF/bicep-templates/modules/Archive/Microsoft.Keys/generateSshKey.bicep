@description('Name of the Key')
param keyName string

@description('Location of the sshKey')
param location string

@description('tags')
param tags object

@description('publicKeyName')
@secure()
param publicKeyName string

resource symbolicname 'Microsoft.Compute/sshPublicKeys@2022-08-01' = {
  name: keyName
  location: location
  tags: tags  
  // properties: {
  //   publicKey: publicKeyName
  // }
}
