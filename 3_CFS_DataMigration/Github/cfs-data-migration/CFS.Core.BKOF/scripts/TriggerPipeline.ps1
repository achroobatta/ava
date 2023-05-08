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
  $WorkItemId,
  $ResourceLocation,
  $MachineName,
  $UltraSSDEnabled,
  $RunType,
  $DestStorageAccount,
  $AppName,
  $Owner,
  $CostCenterCode,
  $WarrantyPeriod,
  $Environment,
  $FileSize,
  $SourceDataType,
  $SourceLocation,
  $SourceStorageAccountFromPipeline,
  $SrcSftpCtn,
  $SrcSftpAcctNm,
  $SrcSftpPass,
  $SrcSftpKey,
  $CBASFTPSourcePath,
  $SecretName,
  $KeyVaultNameforSecret,
  $TargetDataType,
  $VendorName,
  $IpTobeWhiteListed,
  $ExternalHighPortForSFTP,
  $VendorSuppliedPubKey,
  $EmailAddress,
  $ExternalVendorEmailContact,
  $CR
)

#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Start_Pipeline{
  <#
        .SYNOPSIS
        Triggers an existing pipeline.

        .DESCRIPTION
        Triggers an existing pipeline.

        #>
  Param(

    $PipelineId,
    $PAT,
    $WorkItemId,
    $ResourceLocation,
    $MachineName,
    $UltraSSDEnabled,
    $RunType,
    $DestStorageAccount,
    $AppName,
    $Owner,
    $CostCenterCode,
    $WarrantyPeriod,
    $Environment,
    $FileSize,
    $SourceDataType,
    $SourceLocation,
    $SourceStorageAccountFromPipeline,
    $SrcSftpCtn,
    $SrcSftpAcctNm,
    $SrcSftpPass,
    $SrcSftpKey,
    $CBASFTPSourcePath,
    $SecretName,
    $KeyVaultNameforSecret,
    $TargetDataType,
    $VendorName,
    $IpTobeWhiteListed,
    $ExternalHighPortForSFTP,
    $VendorSuppliedPubKey,
    $EmailAddress,
    $ExternalVendorEmailContact,
    $CR
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
            "resourceLocation": "--RESOURCELOCATION--",
            "ultraSSDEnabled": "--ULTRASSDENABLED--",
            "machineName": "--MACHINENAME--",
            "runType": "--RUNTYPE--",
            "destStorageAccount": "--DESTSTORAGEACCOUNT--",
            "appName": "--APPNAME--",
            "owner": "--OWNER--",
            "costCenterCode": "--COSTCENTERCODE--",
            "warrantyPeriod": "--WARRANTYPERIOD--",
            "deployEnvironment": "--DEPLOYENVIRONMENT--",
            "fileSize": "--FILESIZE--",
            "sourceDataType": "--SOURCEDATATYPE--",
            "sourceLocation": "--SOURCELOCATION--",
            "sourceStorageAccountFromPipeline": "--SOURCESTORAGEACCOUNTFROMPIPELINE--",
            "srcSftpCtn": "--SRCSFTPCTN--",
            "srcSftpAcctNm": "--SRCSFTPACCTNM--",
            "srcSftpPass": "--SRCSFTPPASS--",
            "srcSftpKey": "--SRCSFTPKEY--",
            "CBASFTPSourcePath": "--CBASFTPSOURCEPATH--",
            "secretName": "--SECRETNAME--",
            "keyVaultNameforSecret": "--KEYVAULTNAMEFORSECRET--",
            "targetDataType": "--TARGETDATATYPE--",
            "vendorName": "--VENDORNAME--",
            "ipTobeWhiteListed": "--IPTOBEWHITELISTED--",
            "ExternalHighPortForSFTP": "--EXTERNALHIGHPORTFORSFTP--",
            "vendorSuppliedPubKey": "--VENDORSUPPLIEDPUBKEY--",
            "emailAddress": "--EMAILADDRESS--",
            "ExternalVendorEmailContact": "--ExternalVendorEmailContact--"
          },
          "resources": {
            "repositories": {
                "self": {
                    "refName": "refs/heads/--BRANCHNAME--"
                  }
              }
          }
        }'
      if([string]::IsNullOrEmpty($SrcSftpCtn) -or $SourceDataType -eq 'databox' )
      {
        $SrcSftpCtn = "na"
      }
      if([string]::IsNullOrEmpty($SrcSftpAcctNm) -or $SourceDataType -eq 'databox')
      {
        $SrcSftpAcctNm = "na"
      }
      if([string]::IsNullOrEmpty($SrcSftpPass) -or $SourceDataType -eq 'databox' )
      {
        $SrcSftpPass = "na"
      }
      if([string]::IsNullOrEmpty($SrcSftpKey) -or $SourceDataType -eq 'databox')
      {
        $SrcSftpKey = "na"
      }
      if([string]::IsNullOrEmpty($CBASFTPSourcePath) -or $SourceDataType -eq 'databox')
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
      if($CR -eq 'true')
      {
        $BranchName = 'feature/CR'
      }
      if([string]::IsNullOrEmpty($MachineName))
      {
        $MachineName = "new"
      }
      $CBASFTPSourcePath = $CBASFTPSourcePath -replace ' ','*'
      $AppName = $AppName -replace ' ','*'
      $FileSize = $FileSize.Trim()
      $FileSize = $FileSize -replace '\s+', ' '

      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--BRANCHNAME--", $BranchName)

      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--WORKITEMID--", $WorkItemId)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--RESOURCELOCATION--", $ResourceLocation)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--MACHINENAME--", $MachineName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--ULTRASSDENABLED--", $UltraSSDEnabled)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--RUNTYPE--", $RunType)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--DESTSTORAGEACCOUNT--", $DestStorageAccount)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--APPNAME--", $AppName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--OWNER--", $Owner)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--COSTCENTERCODE--", $CostCenterCode)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--WARRANTYPERIOD--", $WarrantyPeriod)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--DEPLOYENVIRONMENT--", $Environment)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--FILESIZE--", $FileSize)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SOURCEDATATYPE--", $SourceDataType)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SOURCELOCATION--", $SourceLocation)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SOURCESTORAGEACCOUNTFROMPIPELINE--", $SourceStorageAccountFromPipeline)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SRCSFTPCTN--", $SrcSftpCtn)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SRCSFTPACCTNM--", $SrcSftpAcctNm)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SRCSFTPPASS--", $SrcSftpPass)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SRCSFTPKEY--", $SrcSftpKey)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--CBASFTPSOURCEPATH--", $CBASFTPSourcePath)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--SECRETNAME--", $SecretName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--KEYVAULTNAMEFORSECRET--", $KeyVaultNameforSecret)
      $TargetDataType = $TargetDataType.ToLower()
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--TARGETDATATYPE--", $TargetDataType)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--VENDORNAME--", $VendorName)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--IPTOBEWHITELISTED--", $IpTobeWhiteListed)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--EXTERNALHIGHPORTFORSFTP--", $ExternalHighPortForSFTP)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--VENDORSUPPLIEDPUBKEY--", $VendorSuppliedPubKey)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--EMAILADDRESS--", $EmailAddress)
      $triggerPipelineReqBod = $triggerPipelineReqBod.Replace("--ExternalVendorEmailContact--", $ExternalVendorEmailContact)

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
 -WorkItemId  $WorkItemId `
 -ResourceLocation $ResourceLocation `
 -MachineName $MachineName `
 -UltraSSDEnabled $UltraSSDEnabled `
 -RunType $RunType `
 -DestStorageAccount $DestStorageAccount `
 -AppName $AppName `
 -Owner $Owner `
 -CostCenterCode $CostCenterCode `
 -WarrantyPeriod $WarrantyPeriod `
 -Environment $Environment `
 -FileSize $FileSize `
 -SourceDataType $SourceDataType `
 -SourceLocation $SourceLocation `
 -SourceStorageAccountFromPipeline $SourceStorageAccountFromPipeline `
 -SrcSftpCtn $SrcSftpCtn `
 -SrcSftpAcctNm $SrcSftpAcctNm `
 -SrcSftpPass $SrcSftpPass `
 -SrcSftpKey $SrcSftpKey `
 -CBASFTPSourcePath $CBASFTPSourcePath `
 -SecretName $SecretName `
 -KeyVaultNameforSecret $KeyVaultNameforSecret `
 -TargetDataType $TargetDataType `
 -VendorName $VendorName `
 -IpTobeWhiteListed $IpTobeWhiteListed `
 -ExternalHighPortForSFTP $ExternalHighPortForSFTP `
 -VendorSuppliedPubKey $VendorSuppliedPubKey `
 -EmailAddress $EmailAddress `
 -ExternalVendorEmailContact $ExternalVendorEmailContact `
 -CR $CR
if($TriggerPipeline -contains $false)
{
  Write-Error "There is an error in triggering the pipeline."
}
elseif($TriggerPipeline -contains $true)
{
    Write-Information -MessageData "Triggered the pipeline successfully." -InformationAction Continue
}

