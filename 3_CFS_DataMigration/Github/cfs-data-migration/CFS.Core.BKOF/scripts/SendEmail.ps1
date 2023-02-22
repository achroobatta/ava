param(
    $fileName,
    $file,
    [Parameter(Mandatory=$true)]
    [string] $clientId,
    [Parameter(Mandatory=$true)]
    [string] $clientSecret,
    [Parameter(Mandatory=$true)]
    [string] $tenantId,
    [Parameter(Mandatory=$true)]
    [string] $senderEmailAddress,
    [Parameter(Mandatory=$true)]
    [string] $receiverEmailAddress,
    [Parameter(Mandatory=$true)]
    [string] $emailSubject,
    [Parameter(Mandatory=$true)]
    [string] $emailContent,
    [Parameter(Mandatory=$false)]
    [string] $logFilePath = ""
)

if ($logFilePath -ne ""){
  Write-Output "Entering into email task" >> $logFilePath
}

if(![string]::IsNullOrEmpty($file) -or ![string]::IsNullOrEmpty($fileName) )
{
  #Convert File to Base 64 String
  $base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($file))
  $attachment = @"
  [
    {
      "@odata.type": "#microsoft.graph.fileAttachment",
      "name": "$fileName",
      "contentType": "text/plain",
      "contentBytes": "$base64string"
    }
  ]
"@
  if ($logFilePath -ne ""){
    Write-Output "Email Attachment created" >> $logFilePath
  }
}
else {
 $attachment = "[]"
 if ($logFilePath -ne ""){
  Write-Output "No Email attachment created" >> $logFilePath
  }
}

#Create Header for Access Token Http Request
$accessTokenRequestHeader = @{
    "Content-Type" = "application/x-www-form-urlencoded"
}

$accessTokenRequestBody = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default"
$accessTokenRequestUri = "https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token"
$accessTokenRequest = Invoke-RestMethod $accessTokenRequestUri  -Method 'POST' -Headers $accessTokenRequestHeader -Body $accessTokenRequestBody
if(![string]::IsNullOrEmpty($accessTokenRequest.access_token))
{
  $accessToken = $accessTokenRequest.access_token

  $sendEmailUri = "https://graph.microsoft.com/v1.0/users/" + $senderEmailAddress + "/sendMail"
  $sendEmailHeader = @{authorization = "Bearer $accessToken"}
  $sendEmailBody = @"
                      {
                          "message": {
                            "subject": "$emailSubject",
                            "body": {
                              "contentType": "HTML",
                              "content": "$emailContent"
                            },
                            "toRecipients": [
                              {
                                "emailAddress": {
                                  "address": "$receiverEmailAddress"
                                }
                              }
                            ],
                            "attachments": $attachment
                          },
                          "saveToSentItems": "false"
                        }
"@

  if ($logFilePath -ne ""){
    Write-Output "Executing Invoke-RestMethod" >> $logFilePath
  }

  $sendEmailRequest = Invoke-RestMethod -Uri $sendEmailUri  -Method Post -Headers $sendEmailHeader -Body $sendEmailBody -ContentType 'application/json'

  if ($logFilePath -ne ""){
    Write-Output $sendEmailRequest >> $logFilePath
    }

  if ($logFilePath -ne ""){
    Write-Output "Exiting from email task" >> $logFilePath
  }
}
else {
  if ($logFilePath -ne ""){
    Write-Output "There is an error getting the access token required." >> $logFilePath
    Write-Output "Error: " $accessTokenRequest >> $logFilePath
    }
}