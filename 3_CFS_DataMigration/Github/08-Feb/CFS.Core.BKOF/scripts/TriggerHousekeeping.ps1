param
(
    [Parameter(Mandatory=$true)]
    [int]$taskNumber,
    [Parameter(Mandatory=$true)]
    [string]$deployEnvironment,
    [Parameter(Mandatory=$true)]
    [string]$vmName,
    [Parameter(Mandatory=$true)]
    [string]$vmRG,
    [Parameter(Mandatory=$true)]
    [string]$diagStorageAccount,
    [Parameter(Mandatory=$true)]
    [string]$resourceLocation,
    [Parameter(Mandatory=$true)]
    [string]$emailAddress,
    [Parameter(Mandatory=$true)]
    [string]$commRG,
    [Parameter(Mandatory=$true)]
    [string]$sftpLocalUser,
    [Parameter(Mandatory=$true)]
    [string]$targetDataType,
    [Parameter(Mandatory=$true)]
    [string]$destStorageAccount,
    [Parameter(Mandatory=$true)]
    [string]$destContainerName,
    [Parameter(Mandatory=$true)]
    [String]$keyVaultNameforSecret
)

Function Start_Pipeline
{
    Param
    (
        $PAT,
        $taskNumber,
        $project,
        $url,
        $resourceLocation,
        $vmName, $vmRG,
        $diagStorageAccount,
        $targetDataType,
        $emailAddress,
        $deployEnvironment,
        $commRG,
        $sftpLocalUser,
        $destStorageAccount,
        $destContainerName,
        $keyVaultNameforSecret
    )

    Connect-AzAccount -identity -Verbose -Force -SkipContextPopulation -ErrorAction Stop
    $keySecret = $destContainerName + "secret"
    $ctx = (Get-AzStorageAccount -ResourceGroupName $commRG -Name $destStorageAccount).Context
    $result = Get-AzStorageContainer -Name $destContainerName* -Context $ctx | Get-AzStorageBlob | Select-Object name
    $stgfname = ($result).Name

    Try{
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
      $header = @{authorization = "Basic $token"}

      $triggerPipelineApi = "$($url)$project/_apis/pipelines/152/runs" + "?api-version=7.1-preview.1"
      $triggerPipelineReqBod = '
        {
          "templateParameters": {
            "taskNumber": "--taskNumber--",
            "environment": "--environment--",
            "vmName": "--vmName--",
            "vmRgName": "--vmRgName--",
            "diagStorageAccount": "--diagStorageAccount--",
            "resourceLocation": "--resourceLocation--",
            "receiverEmailAddress": "--receiverEmailAddress--",
            "commRGName": "--commRGName--",
            "sftpLocalUser": "--sftpLocalUser--",
            "targetDataType": "--targetDataType--",
            "destStorageAccount": "--destStorageAccount--",
            "destContainerName": "--destContainerName--",
            "destFileName": "--destFileName--",
            "zipFileSecretName": "--zipFileSecretName--",
            "keyVaultNameforSecret": "--keyVaultNameforSecret--"
          },
          "resources": {
            "repositories": {
                "self": {
                    "refName": "refs/heads/main"
                  }
              }
          }
        }'
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--taskNumber--", $taskNumber)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--environment--", $deployEnvironment)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--vmName--", $vmName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--vmRgName--", $vmRG)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--strAccName--", $diagStorageAccount)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--resourceLocation--", $resourceLocation)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--receiverEmailAddress--", $emailAddress)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--commRGName--", $commRG)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--sftpLocalUser--", $sftpLocalUser)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--targetDataType--", $targetDataType)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--destStorageAccount--", $destStorageAccount)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--destContainerName--", $destContainerName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--keyVaultNameforSecret--", $keyVaultNameforSecret)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--zipFileSecretName--", $keySecret)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--destFileName--", $stgfname)
      Invoke-RestMethod -Uri $triggerPipelineApi -Method Post -Headers $header -Body $triggerPipelineReqBod -ContentType 'application/json' -ErrorAction Stop

      return $true

    }
    Catch
    {
      return $false
    }
}

$url = "https://dev.azure.com/AUSUP/"
$project = "core-it"
$PAT = Get-AzKeyVaultSecret -VaultName $keyVaultNameforSecret -Name PAT -AsPlainText
Start_Pipeline -PAT $PAT -taskNumber $taskNumber -resourceLocation $resourceLocation -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -emailAddress $emailAddress -deployEnvironment $deployEnvironment -commRG $commRG -sftpLocalUser $sftpLocalUser -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -targetDataType $targetDataType -project $project -url $url