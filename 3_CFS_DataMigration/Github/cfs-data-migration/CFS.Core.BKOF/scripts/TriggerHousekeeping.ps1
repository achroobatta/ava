param
(
    [Parameter(Mandatory=$false)]
    [int]$taskNumber,
    [Parameter(Mandatory=$false)]
    [string]$deployEnvironment,
    [Parameter(Mandatory=$false)]
    [string]$vmName,
    [Parameter(Mandatory=$false)]
    [string]$vmRG,
    [Parameter(Mandatory=$false)]
    [string]$diagStorageAccount,
    [Parameter(Mandatory=$false)]
    [string]$resourceLocation,
    [Parameter(Mandatory=$false)]
    [string]$emailAddress,
    [Parameter(Mandatory=$false)]
    [string]$commRG,
    [Parameter(Mandatory=$false)]
    [string]$targetDataType,
    [Parameter(Mandatory=$false)]
    [string]$destStorageAccount,
    [Parameter(Mandatory=$false)]
    [string]$destContainerName,
    [Parameter(Mandatory=$false)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$false)]
    [String]$clientEmailAddress,
    [Parameter(Mandatory=$false)]
    [String]$sftpUsername,
    [Parameter(Mandatory=$false)]
    [String]$runType,
    [Parameter(Mandatory=$false)]
    [String]$manualVerificationEmail,
    [Parameter(Mandatory=$false)]
    [String]$tvtresult,
    [Parameter(Mandatory=$false)]
    [String]$unzipPath,
    [Parameter(Mandatory=$false)]
    [string]$appName,
    [Parameter(Mandatory=$false)]
    [string]$subId,
    [Parameter(Mandatory=$false)]
    [string]$subTenantId,
    [Parameter(Mandatory=$false)]
    [string]$realTimeMonitoringEmail,
    [Parameter(Mandatory=$false)]
    [string]$threatLogs,
    [Parameter(Mandatory=$false)]
    [string]$stgMisMatch,
    [Parameter(Mandatory=$false)]
    [string]$sourceDatatype,
    [Parameter(Mandatory=$false)]
    [string]$etlDestStorageAccountName
)

function azconnect()
{
    param ($subId, $subTenantId)

    $attempt = 1
    $result = Get-AzContext
    if($null -eq $result)
    {
        $azctx = $false
    }
    else
    {
        $azctx = $true
    }
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connecting to Azure") >> $logFilePath
    while($attempt -le 3 -and -not $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Attempt $attempt") >> $logFilePath
        try
        {
            Connect-AzAccount -Identity -Tenant $subTenantId -Subscription $subId -Force
            $result = Get-AzContext
            if($null -ne $result)
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Connection with azure established") >> $logFilePath
                break
            }
        }
        catch
        {
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed to established connection") >> $logFilePath
            Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Sleep for 60 Seconds") >> $logFilePath
            Start-Sleep -Seconds 60
            if($attempt -gt 2)
            {
                Start-Sleep -Seconds 60
            }
        }
        $attempt += 1
    }
    $azresult = Get-AzContext
    if($null -eq $azresult)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to established connection") >> $logFilePath
        break
    }
}


Function Start_Pipeline
{
    Param
    (
        $PAT,
        $taskNumber,
        $project,
        $url,
        $resourceLocation,
        $vmName,
        $vmRG,
        $diagStorageAccount,
        $targetDataType,
        $emailAddress,
        $deployEnvironment,
        $commRG,
        $sftpUsername,
        $destStorageAccount,
        $destContainerName,
        $keyVaultNameforSecret,
        $clientEmailAddress,
        $runType,
        $manualVerificationEmail,
        $unzipPath,
        $appName,
        $threatLogs,
        $realTimeMonitoringEmail,
        $stgMisMatch,
        $sourceDatatype,
        $etlDestStorageAccountName
    )

    if($targetDataType -eq "external")
    {
      $keySecret = $sftpUsername + "7ZipPassword"
    }
    else
    {
      $keySecret = " "
    }

    $ctx = (Get-AzStorageAccount -ResourceGroupName $commRG -Name $destStorageAccount).Context
    $result = Get-AzStorageContainer -Name $destContainerName* -Context $ctx | Get-AzStorageBlob | Select-Object name
    if ($null -eq $result)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"No Files Existing in $destStorageAccount Container") >> $logFilePath
    }
    else
    {
      $stgfname = (Get-ChildItem -Path $unzipPath).BaseName
    }

    $count = $stgfname.Count
    if($count -gt 1)
    {
        $stgfname = $stgfname -join "</p><p>"
    }

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
            "targetDataType": "--targetDataType--",
            "destStorageAccount": "--destStorageAccount--",
            "destContainerName": "--destContainerName--",
            "destFileName": "--destFileName--",
            "zipFileSecretName": "--zipFileSecretName--",
            "keyVaultNameforSecret": "--keyVaultNameforSecret--",
            "clientEmailAddress": "--clientEmailAddress--",
            "manualVerificationEmail": "--manualVerificationEmail--",
            "runType": "--runType--",
            "appName": "--appName--",
            "tvtresult": " ",
            "threatLogs": "--THREATLOGS--",
            "realTimeMonitoringEmail": "--REALTIMEMONITORING--",
            "stgMisMatch": "--stgMisMatch--",
            "sourceDatatype": "--sourceDatatype--",
            "etlDestStorageAccountName": "--etlDestStorageAccountName--"
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
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--diagStorageAccount--", $diagStorageAccount)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--resourceLocation--", $resourceLocation)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--receiverEmailAddress--", $emailAddress)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--commRGName--", $commRG)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--targetDataType--", $targetDataType)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--destStorageAccount--", $destStorageAccount)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--destContainerName--", $destContainerName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--keyVaultNameforSecret--", $keyVaultNameforSecret)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--zipFileSecretName--", $keySecret)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--destFileName--", $stgfname)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--clientEmailAddress--", $clientEmailAddress)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--runType--", $runType)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--manualVerificationEmail--", $manualVerificationEmail)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--appName--", $appName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--THREATLOGS--", $threatLogs)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--REALTIMEMONITORING--", $realTimeMonitoringEmail)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--stgMisMatch--", $stgMisMatch)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--sourceDatatype--", $sourceDatatype)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--etlDestStorageAccountName--", $etlDestStorageAccountName)

      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing Invoke-RestMethod") >> $logFilePath
      Invoke-RestMethod -Uri $triggerPipelineApi -Method Post -Headers $header -Body $triggerPipelineReqBod -ContentType 'application/json' -ErrorAction Stop
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully Triggered Invoke-RestMethod") >> $logFilePath
      return $true

    }
    Catch
    {
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered while running Invoke-RestMethod") >> $logFilePath
      return $false
    }
}

function Mismatch_Pipeline
{
  Param
    (
        $PAT,
        $project,
        $url,
        $vmName,
        $emailAddress,
        $deployEnvironment,
        $manualVerificationEmail,
        $tvtresult,
        $appName,
        $threatLogs,
        $realTimeMonitoringEmail,
        $stgMisMatch,
        $sourceDatatype,
        $taskNumber,
        $targetDataType
    )

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
            "vmRgName": " ",
            "diagStorageAccount": " ",
            "resourceLocation": " ",
            "receiverEmailAddress": "--receiverEmailAddress--",
            "commRGName": " ",
            "targetDataType": "--targetDataType--",
            "destStorageAccount": " ",
            "destContainerName": " ",
            "destFileName": " ",
            "zipFileSecretName": " ",
            "keyVaultNameforSecret": " ",
            "clientEmailAddress": " ",
            "manualVerificationEmail": "--manualVerificationEmail--",
            "tvtresult": "--tvtresult--",
            "appName": "--appName--",
            "runType": " ",
            "threatLogs": "--THREATLOGS--",
            "realTimeMonitoringEmail": "--REALTIMEMONITORING--",
            "stgMisMatch": "--stgMisMatch--",
            "sourceDatatype": "--sourceDatatype--",
            "etlDestStorageAccountName": " "
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
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--receiverEmailAddress--", $emailAddress)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--manualVerificationEmail--", $manualVerificationEmail)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--tvtresult--", $tvtresult)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--appName--", $appName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--targetDataType--", $targetDataType)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--THREATLOGS--", $threatLogs)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--REALTIMEMONITORING--", $realTimeMonitoringEmail)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--stgMisMatch--", $stgMisMatch)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--sourceDatatype--", $sourceDatatype)

      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing Invoke-RestMethod") >> $logFilePath
      Invoke-RestMethod -Uri $triggerPipelineApi -Method Post -Headers $header -Body $triggerPipelineReqBod -ContentType 'application/json' -ErrorAction Stop
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully Triggered Invoke-RestMethod") >> $logFilePath
      return $true

    }
    Catch
    {
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered while running Invoke-RestMethod: $_") >> $logFilePath
      return $false
    }
}

#Back Log path
$logFilePath = "$PSScriptRoot\logging_TriggerHousekeeping.txt"

try
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing Start_Pipeline function...") >> $logFilePath

    $azctx = Get-AzContext
    if($null -eq $azctx)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"VM is not connected in Azure") >> $logFilePath
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Reconnecting to azure...") >> $logFilePath
        azconnect -subId $subId -subTenantId $subTenantId | Out-Null
    }

    $url = "https://dev.azure.com/AUSUP/"
    $project = "core-it"

    $PAT = Get-AzKeyVaultSecret -VaultName $keyVaultNameforSecret -Name PAT -AsPlainText
    if ($null -eq $PAT)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Unable to get PAT from key vault") >> $logFilePath
    }
    if($manualVerificationEmail -eq "true")
    {
      Mismatch_Pipeline -PAT $PAT -taskNumber $taskNumber -vmName $vmName -emailAddress $emailAddress -deployEnvironment $deployEnvironment -manualVerificationEmail $manualVerificationEmail -tvtresult $tvtresult -project $project -url $url -appName $appName -realTimeMonitoringEmail $realTimeMonitoringEmail -threatLogs $threatLogs -stgMisMatch $stgMisMatch -sourceDatatype $sourceDatatype -targetDataType $targetDataType
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    }
    elseif($realTimeMonitoringEmail -eq "true")
    {
      Mismatch_Pipeline -PAT $PAT -taskNumber $taskNumber -vmName $vmName -emailAddress $emailAddress -deployEnvironment $deployEnvironment -manualVerificationEmail $manualVerificationEmail -tvtresult $tvtresult -project $project -url $url -appName $appName -realTimeMonitoringEmail $realTimeMonitoringEmail -threatLogs $threatLogs -stgMisMatch $stgMisMatch -sourceDatatype $sourceDatatype -targetDataType $targetDataType
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    }
    elseif($stgMisMatch -ne "na")
    {
      Mismatch_Pipeline -PAT $PAT -taskNumber $taskNumber -vmName $vmName -emailAddress $emailAddress -deployEnvironment $deployEnvironment -manualVerificationEmail $manualVerificationEmail -tvtresult $tvtresult -project $project -url $url -appName $appName -realTimeMonitoringEmail $realTimeMonitoringEmail -threatLogs $threatLogs -stgMisMatch $stgMisMatch -sourceDatatype $sourceDatatype -targetDataType $targetDataType
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    }
    else
    {
      Start_Pipeline -PAT $PAT -taskNumber $taskNumber -resourceLocation $resourceLocation -vmName $vmName -vmRG $vmRG -diagStorageAccount $diagStorageAccount -emailAddress $emailAddress -deployEnvironment $deployEnvironment -commRG $commRG -destStorageAccount $destStorageAccount -destContainerName $destContainerName -keyVaultNameforSecret $keyVaultNameforSecret -targetDataType $targetDataType -project $project -url $url -clientEmailAddress $clientEmailAddress -runType $runType -manualVerificationEmail $manualVerificationEmail -sftpUsername $sftpUsername -unzipPath $unzipPath -appName $appName -threatLogs $threatLogs -realTimeMonitoringEmail $realTimeMonitoringEmail -stgMisMatch $stgMisMatch -sourceDatatype $sourceDatatype -etlDestStorageAccountName $etlDestStorageAccountName
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
    }
}
catch
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encounted while executing Start_Pipeline function") >> $logFilePath
}