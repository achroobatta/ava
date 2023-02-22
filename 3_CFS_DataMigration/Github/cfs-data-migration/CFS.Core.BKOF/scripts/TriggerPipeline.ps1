<#
.SYNOPSIS
 Trigger a pipeline.
.DESCRIPTION
  This script will be used to trigger an existing Azure DevOps pipeline.


.NOTES
  Version:        1.0
  Author:         Abaigail Rose Artagame
  Creation Date:  29/11/2022
  Purpose/Change: Initial script development


#>


#-----------------------------------------------------------[Declarations]------------------------------------------------------------
param(
  $PipelineId,
  $PAT,
  $AppName,
  $CostCenterCode,
  $ReqEmailAddress,
  $Environment,
  $FileSize,
  $IpTobeWhiteListed,
  $KeyVaultNameforSecret,
  $NumberOfFiles,
  $Owner,
  $SecretName,
  $SourceLocation,
  $SourceDataType,
  $TargetDataType,
  $VendorName,
  $WarrantyPeriod,
  $WorkItemId,
  $ResourceLocation,
  $UltraSSDEnabled,
  $VendorSuppliedPubKey,
  $CBASFTPSourcePath,
  $RunType,
  $DestStorageAccount,
  $ClientEmailAddress,
  $MachineName,
  $SrcSftpCtn,
  $SrcSftpAcctNm,
  $SrcSftpPass,
  $SrcSftpKey
)

#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Start_Pipeline{
  <#
        .SYNOPSIS
        Triggers an existing pipeline.

        .DESCRIPTION
        Triggers an existing pipeline.

        .PARAMETER PipelineId
        ID of the Pipeline to be triggered.

        .PARAMETER PAT
        Personal Access Token used for Authentication.

        .PARAMETER AppName
        AppName needs to be passed to other pipeline when triggering

        .PARAMETER CostCenterCode
        CostCenterCode needs to be passed to other pipeline when triggering

        .PARAMETER ReqEmailAddress
        ReqEmailAddress needs to be passed to other pipeline when triggering

        .PARAMETER Environment
        Environment needs to be passed to other pipeline when triggering

        .PARAMETER FileSize
        FileSize needs to be passed to other pipeline when triggering

        .PARAMETER SourceDataType
        SourceDataType needs to be passed to other pipeline when triggering

        .PARAMETER IpTobeWhiteListed
        IpTobeWhiteListed needs to be passed to other pipeline when triggering

        .PARAMETER KeyVaultNameforSecret
        KeyVaultNameforSecret needs to be passed to other pipeline when triggering

        .PARAMETER NumberOfFiles
        NumberOfFiles needs to be passed to other pipeline when triggering

        .PARAMETER Owner
        Owner needs to be passed to other pipeline when triggering

        .PARAMETER SecretName
        SecretName needs to be passed to other pipeline when triggering

        .PARAMETER SourceLocation
        SourceLocation needs to be passed to other pipeline when triggering

        .PARAMETER SrcSftpCtn
        SrcSftpCtn needs to be passed to other pipeline when triggering

        .PARAMETER SrcSftpAcctNm
        SrcSftpAcctNm needs to be passed to other pipeline when triggering

        .PARAMETER SrcSftpPass
        SrcSftpPass needs to be passed to other pipeline when triggering

        .PARAMETER SrcSftpKey
        SrcSftpKey needs to be passed to other pipeline when triggering

        .PARAMETER TargetDataType
        TargetDataType used to determine what pipeline will be triggered

        .PARAMETER VendorName
        VendorName needs to be passed to other pipeline when triggering

        .PARAMETER WarrantyPeriod
        WarrantyPeriod needs to be passed to other pipeline when triggering

        .PARAMETER WorkItemId
        Work Item Id needs to be passed to other pipeline when triggering

        .PARAMETER ResourceLocation
        ResourceLocation needs to be passed to other pipeline when triggering

        .PARAMETER UltraSSDEnabled
        UltraSSDEnabled needs to be passed to other pipeline when triggering

        .PARAMETER BranchName
        BranchName used to determine what branch will be used to trigger the pipeline

        .PARAMETER VendorSuppliedPubKey
        VendorSuppliedPubKey needs to be passed to other pipeline when triggering

        .PARAMETER CBASFTPSourcePath
        CBASFTPSourcePath needs to be passed to other pipeline when triggering

        .PARAMETER RunType
        RunType needs to be passed to other pipeline when triggering

        .PARAMETER DestStorageAccount
        DestStorageAccount needs to be passed to other pipeline when triggering

        .PARAMETER ClientEmailAddress
        ClientEmailAddress needs to be passed to other pipeline when triggering

        #>
  Param(

    $PipelineId,
    $PAT,
    $AppName,
    $CostCenterCode,
    $ReqEmailAddress,
    $Environment,
    $FileSize,
    $IpTobeWhiteListed,
    $KeyVaultNameforSecret,
    $Owner,
    $SecretName,
    $SourceLocation,
    $SourceDataType,
    $TargetDataType,
    $VendorName,
    $WarrantyPeriod,
    $WorkItemId,
    $ResourceLocation,
    $UltraSSDEnabled,
    $SrcSftpCtn,
    $SrcSftpAcctNm,
    $SrcSftpPass,
    $SrcSftpKey,
    $VendorSuppliedPubKey,
    $CBASFTPSourcePath,
    $RunType,
    $DestStorageAccount,
    $ClientEmailAddress,
    $MachineName
  )
  Begin{
    Write-Information -MessageData "Triggering Pipeline $PipelineId..." -InformationAction Continue
  }
  Process
  {
    Try{
      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}
      $triggerPipelineApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/pipelines/$PipelineId/runs" + "?api-version=7.1-preview.1"
      $triggerPipelineReqBod = '
        {
          "templateParameters": {
            "taskNumber": "--WORKITEMID--",
            "deployEnvironment": "--DEPLOYENVIRONMENT--",
            "resourceLocation": "--RESOURCELOCATION--",
            "appName": "--APPNAME--",
            "costCenterCode": "--COSTCENTERCODE--",
            "reqEmailAddress": "--EMAILADDRESS--",
            "fileSize": "--FILESIZE--",
            "ipTobeWhiteListed": "--IPTOBEWHITELISTED--",
            "keyVaultNameforSecret": "--KEYVAULTNAMEFORSECRET--",
            "owner": "--OWNER--",
            "secretName": "--SECRETNAME--",
            "sourceLocation": "--SOURCELOCATION--",
            "sourceDataType": "--SOURCEDATATYPE--",
            "targetDataType": "--TARGETDATATYPE--",
            "vendorName": "--VENDORNAME--",
            "warrantyPeriod": "--WARRANTYPERIOD--",
            "ultraSSDEnabled": "--ULTRASSDENABLED--",
            "srcSftpCtn": "--SRCSFTPCTN--",
            "srcSftpAcctNm": "--SRCSFTPACCTNM--",
            "srcSftpPass": "--SRCSFTPPASS--",
            "srcSftpKey": "--SRCSFTPKEY--",
            "vendorSuppliedPubKey": "--VENDORSUPPLIEDPUBKEY--",
            "cbaSftpSourcePath" : "--CBASFTPSOURCEPATH--",
            "runType": "--RUNTYPE--",
            "destStorageAccount": "--DESTSTORAGEACCOUNT--",
            "machineName": "--MACHINENAME--",
            "clientEmailAddress": "--CLIENTEMAILADDRESS--"
          },
          "resources": {
            "repositories": {
                "self": {
                    "refName": "refs/heads/--BRANCHNAME--"
                  }
              }
          }
        }'
      if([string]::IsNullOrEmpty($SrcSftpCtn))
      {
        $SrcSftpCtn = "na"
      }
      if([string]::IsNullOrEmpty($SrcSftpAcctNm))
      {
        $SrcSftpAcctNm = "na"
      }
      if([string]::IsNullOrEmpty($SrcSftpPass))
      {
        $SrcSftpPass = "na"
      }
      if([string]::IsNullOrEmpty($SrcSftpKey))
      {
        $SrcSftpKey = "na"
      }
      if([string]::IsNullOrEmpty($CBASFTPSourcePath))
      {
        $CBASFTPSourcePath = "na"
      }
      if($Environment -eq 'Non-Production')
      {
        $BranchName = 'develop'
      }
      elseif($Environment -eq 'Production')
      {
        $BranchName = 'main'
      }
      if([string]::IsNullOrEmpty($MachineName))
      {
        $MachineName = "new"
      }

      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--WORKITEMID--", $WorkItemId)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--DEPLOYENVIRONMENT--", $Environment)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--RESOURCELOCATION--", $ResourceLocation)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--APPNAME--", $AppName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--COSTCENTERCODE--", $CostCenterCode)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--EMAILADDRESS--", $ReqEmailAddress)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--FILESIZE--", $FileSize)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--IPTOBEWHITELISTED--", $IpTobeWhiteListed)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--KEYVAULTNAMEFORSECRET--", $KeyVaultNameforSecret)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--OWNER--", $Owner)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SECRETNAME--", $SecretName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SOURCELOCATION--", $SourceLocation)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SOURCEDATATYPE--", $SourceDataType)
      $TargetDataType = $TargetDataType.ToLower()
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--TARGETDATATYPE--", $TargetDataType)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--VENDORNAME--", $VendorName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--WARRANTYPERIOD--", $WarrantyPeriod)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--BRANCHNAME--", $BranchName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--ULTRASSDENABLED--", $UltraSSDEnabled)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SRCSFTPCTN--", $SrcSftpCtn)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SRCSFTPACCTNM--", $SrcSftpAcctNm)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SRCSFTPPASS--", $SrcSftpPass)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SRCSFTPKEY--", $SrcSftpKey)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--VENDORSUPPLIEDPUBKEY--", $VendorSuppliedPubKey)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--CBASFTPSOURCEPATH--", $CBASFTPSourcePath)

      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--RUNTYPE--", $RunType)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--DESTSTORAGEACCOUNT--", $DestStorageAccount)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--CLIENTEMAILADDRESS--", $ClientEmailAddress)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--MACHINENAME--", $MachineName)
      Write-Information -MessageData $triggerPipelineReqBod -InformationAction Continue
      Invoke-RestMethod -Uri $triggerPipelineApi -Method Post -Headers $header -Body $triggerPipelineReqBod -ContentType 'application/json' -ErrorAction Stop

      return $true

    }
    Catch
    {
      return $false
    }
  }
  End{}
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Call Run-Pipeline

$TriggerPipeline = Start_Pipeline -PipelineId $PipelineId `
 -PAT $PAT `
 -AppName $AppName `
 -CostCenterCode $CostCenterCode `
 -ReqEmailAddress $ReqEmailAddress `
 -Environment $Environment `
 -FileSize $FileSize `
 -IpTobeWhiteListed $IpTobeWhiteListed `
 -KeyVaultNameforSecret $KeyVaultNameforSecret `
 -NumberOfFiles $NumberOfFiles `
 -Owner $Owner `
 -SecretName $SecretName `
 -SourceLocation $SourceLocation `
 -SourceDataType $SourceDataType `
 -TargetDataType $TargetDataType `
 -VendorName $VendorName `
 -WarrantyPeriod $WarrantyPeriod `
 -WorkItemId  $WorkItemId `
 -ResourceLocation $ResourceLocation `
 -UltraSSDEnabled $UltraSSDEnabled `
 -SrcSftpCtn $SrcSftpCtn `
 -SrcSftpAcctNm $SrcSftpAcctNm `
 -SrcSftpPass $SrcSftpPass `
 -SrcSftpKey $SrcSftpKey `
 -VendorSuppliedPubKey $VendorSuppliedPubKey `
 -CBASFTPSourcePath $CBASFTPSourcePath `
 -RunType $RunType `
 -DestStorageAccount $DestStorageAccount `
 -ClientEmailAddress $ClientEmailAddress `
 -MachineName $MachineName
if($TriggerPipeline -contains $false)
{
  Write-Error "There is an error in triggering the pipeline."
}
elseif($TriggerPipeline -contains $true)
{
    Write-Information -MessageData "Triggered the pipeline successfully." -InformationAction Continue
}

