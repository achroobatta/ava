<#
.SYNOPSIS
  Download excel file attachment from a work item.
.DESCRIPTION
  This script will be used to download an excel file from an Azure DevOps workitem which contains the values needed to run the main pipeline.

.NOTES
  Version:        1.0
  Author:         Abaigail Rose Artagame
  Creation Date:  29/11/2022
  Purpose/Change: Initial script development


#>


#-----------------------------------------------------------[Declarations]------------------------------------------------------------
param(
  $WorkItemId,
  $PAT
)


#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Get_AttachmentDownloadUrl{
  <#
        .SYNOPSIS
        Gets the attachment download url.

        .DESCRIPTION
        Gets the attachment download url.

        .PARAMETER WorkItemId
        Work Item Id.

        .PARAMETER PAT
        Personal Access Token used for Authentication.

    #>
  Param(

    $WorkItemId,
    $PAT

  )
  Begin{
    Write-Information -MessageData "Getting the attachment download url..." -InformationAction Continue
  }
  Process
  {
    Try{
      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
      $header = @{authorization = "Basic $token"}

      $getAttDlUrlApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/wit/workitems/$WorkItemId" + '?$expand=all&api-version=7.1-preview.3'

      $getAttDlUrl = Invoke-RestMethod -Uri $getAttDlUrlApi -Method Get -Headers $header -ErrorAction Stop

      $getAttDlUrlRes = $getAttDlUrl.relations | Where-Object{$_.rel -eq 'AttachedFile'}
      return $getAttDlUrlRes
    }
    Catch
    {
      return $null
    }
  }
  End{}
}
Function Get_Attachment{
  <#
        .SYNOPSIS
        Downloads the work item attachment

        .DESCRIPTION
        Downloads the work item attachment

        .PARAMETER AttachmentDownloadUrl
        Attachment Download Url

        .PARAMETER FileName
        Attachment File Name

        .PARAMETER PAT
        Personal Access Token used for Authentication.

    #>
  Param(

    $AttachmentDownloadUrl,
    $FileName,
    $PAT

  )
  Begin{
    Write-Information -MessageData "Downloading the attachment..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $getAttDlUrl = Invoke-WebRequest -Uri $AttachmentDownloadUrl -Method Get -Headers $header -ErrorAction Stop
      [System.IO.File]::WriteAllBytes($FileName, $getAttDlUrl.Content)

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

#Call Get_AttachmentDownloadUrl Function
$Attachment = Get_AttachmentDownloadUrl -WorkItemId $WorkItemId -PAT $PAT
$ExcelFileName = $Attachment.attributes.name
if($null -eq $Attachment)
{
  Write-Error "There is an error in getting the attachment download url."
}
Write-Output "##vso[task.setvariable variable=excelFileName]$ExcelFileName"
Write-Output "##vso[task.setvariable variable=ExcelFileName;isOutput=true]$ExcelFileName"
#Call Get_Attachment Function
$DownloadAttachment = Get_Attachment -AttachmentDownloadUrl $Attachment.url -FileName $ExcelFileName -PAT $PAT
if($DownloadAttachment -eq $false)
{
  Write-Error "There is an error in downloading the attachment."
}
Write-Information -MessageData "The attachment have been downloaded." -InformationAction Continue
