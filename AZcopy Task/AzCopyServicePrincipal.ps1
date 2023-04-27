# Set variables
$clientId = "c5d25bfa-49bf-4e62-8668-ff0e70d0dd0b"
$clientSecret = "TdI8Q~yahqPuYURw0MH2oV3KQZL0vVAsktH2HbXs"
$tenantId = "574e14fe-5558-4211-a6a4-818ba8303014"
$storageAccountName = "dsftpnpedcbkof7565"
$containerName = "container7565"
$blobName = "test.txt"
$accessTokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$blobUrl = "https://$storageAccountName.blob.core.windows.net:40001/$containerName/$blobName"
$localFilePath = "C:\0_PROJECTS\test.txt"
 
# Get access token
$body = @{
    grant_type = "client_credentials"
    client_id = $clientId
    client_secret = $clientSecret
    resource = "https://storage.azure.com"
}
$accessTokenResponse = Invoke-RestMethod -Method Post -Uri $accessTokenUrl -Body $body
$accessToken = $accessTokenResponse.access_token
 
# Download blob
Invoke-WebRequest -Uri $blobUrl -Headers  @{ Authorization = "Bearer $accessToken"; "x-ms-version" = "2020-04-08" } -OutFile $localFilePath
