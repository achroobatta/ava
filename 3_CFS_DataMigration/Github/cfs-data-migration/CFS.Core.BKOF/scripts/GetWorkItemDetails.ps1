<#
.SYNOPSIS
  Check if work item state
.DESCRIPTION
  This script will be used to check for the task state

.NOTES
  Version:        2.0
  Author:         Abaigail Rose Artagame
  Creation Date:  25/02/2023
  Purpose/Change: Change Getting of Work Item Id

#>


#-----------------------------------------------------------[Declarations]------------------------------------------------------------
param(
  $PAT,
  $WebHookServiceConnName
)


#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Get_WorkItemId{
  <#
        .SYNOPSIS
        Returns the work item id that triggered the service hook.

        .DESCRIPTION
        Returns the work item id that triggered the service hook.

        .PARAMETER PAT
        Personal Access Token used for Authentication.
    #>
  Param(
    $PAT,
    $WebHookServiceConnName
  )
  Begin{
    Write-Information -MessageData "Getting work item id..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}
      $getWorkItemIdApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/build/builds/$env:BUILD_BUILDID" + "?api-version=7.0"
      Write-Information -MessageData $getWorkItemIdApi -InformationAction Continue
      $getworkItemId = Invoke-RestMethod -Uri $getWorkItemIdApi -Method Get -Headers $header -ErrorAction Stop
      Write-Information -MessageData $getworkItemId -InformationAction Continue
      $triggerPipeline = $getworkItemId.templateParameters.$WebHookServiceConnName | ConvertFrom-Json
      Write-Information -MessageData $triggerPipeline -InformationAction Continue

      if($triggerPipeline.eventType -eq 'workitem.created')
      {
        return $triggerPipeline.resource.id
      }
      elseif($triggerPipeline.eventType -eq 'workitem.updated')
      {
        return $triggerPipeline.resource.workItemId
      }
    }
    Catch
    {
      Write-Information -MessageData $_ -InformationAction Continue
      return $null
    }
  }
  End{}
}
Function Get_WorkItemState{
  <#
        .SYNOPSIS
        Returns the work item id that triggered the service hook.

        .DESCRIPTION
        Returns the work item id that triggered the service hook.

        .PARAMETER WorkItemId
        Id of the Work Item

        .PARAMETER PAT
        Personal Access Token used for Authentication.
    #>
  Param(

  $WorkItemId,
  $PAT

  )
  Begin{
    Write-Information -MessageData "Getting work item state..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $getWorkItemIdApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/wit/workitems/$WorkItemId" + '?$expand=all&api-version=7.1-preview.3'
      $getworkItemId = Invoke-RestMethod -Uri $getWorkItemIdApi -Method Get -Headers $header -ErrorAction Stop
      return $getworkItemId.fields.'System.State'
    }
    Catch
    {
      return $null
    }
  }
  End{}
}
Function Get_WorkItemTag{
  <#
        .SYNOPSIS
        Returns the work item id that triggered the service hook.

        .DESCRIPTION
        Returns the work item id that triggered the service hook.

        .PARAMETER WorkItemId
        Id of the Work Item

        .PARAMETER PAT
        Personal Access Token used for Authentication.
    #>
  Param(

    $WorkItemId,
    $PAT

  )
  Begin{
    Write-Information -MessageData "Getting work item tag..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $getWorkItemIdApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/wit/workitems/$WorkItemId" + '?$expand=all&api-version=7.1-preview.3'
      $getworkItemId = Invoke-RestMethod -Uri $getWorkItemIdApi -Method Get -Headers $header -ErrorAction Stop
      return $getworkItemId.fields.'System.Tags'

    }
    Catch
    {
      return $null
    }
  }
  End{}
}
Function Get_WorkItemUpdates{
  <#
        .SYNOPSIS
        Returns the work item id that triggered the service hook.

        .DESCRIPTION
        Returns the work item id that triggered the service hook.

        .PARAMETER WorkItemId
        Id of the Work Item

        .PARAMETER PAT
        Personal Access Token used for Authentication.
    #>
  Param(

    $WorkItemId,
    $PAT

  )
  Begin{
    Write-Information -MessageData "Getting work item updates..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $getWorkItemUpdatesApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/wit/workItems/$WorkItemId" + '/updates'
      $getWorkItemUpdates = Invoke-RestMethod -Uri $getWorkItemUpdatesApi -Method Get -Headers $header -ErrorAction Stop
      $getWorkItemUpdates = $getWorkItemUpdates.value | Sort-Object -Property id -Descending
      if(![string]::IsNullOrEmpty($getWorkItemUpdates[0].fields.'System.Tags'.newValue))
      {
        return 'true'
      }
      else
      {
        return 'false'
      }
    }
    Catch
    {
      return $null
    }
  }
  End{}
}
#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Call Get_WorkItemId Function
$WorkItemId = Get_WorkItemId -PAT $PAT -WebHookServiceConnName $WebHookServiceConnName
if($null -eq $WorkItemId)
{
  Write-Error "There is an error in getting the work item id."
}
#Save Work Item Id as Stage Output Variable
Write-Output "##vso[task.setvariable variable=WorkItemId;isOutput=true]$WorkItemId"
#Call Get_WorkItemState Function
$WorkItemState = Get_WorkItemState -WorkItemId $WorkItemId -PAT $PAT
if($null -eq $WorkItemState)
{
  Write-Error "There is an error in getting the work item state."
}
#Save Work Item State as Stage Output Variable
Write-Output "##vso[task.setvariable variable=WorkItemState;isOutput=true]$WorkItemState"

#Call Get_WorkItemTag Function
$WorkItemTag = Get_WorkItemTag -WorkItemId $WorkItemId -PAT $PAT
Write-Information -MessageData $WorkItemTag -InformationAction Continue
if($null -eq $WorkItemTag)
{
  Write-Error "There is an error in getting the work item tag."
}
if($WorkItemTag.contains("no attachment"))
{
  $CheckUpdate = Get_WorkItemUpdates -WorkItemId $WorkItemId -PAT $PAT
  Write-Output "##vso[task.setvariable variable=SkippedDownload;isOutput=true]$CheckUpdate"
}
if($WorkItemTag.contains("non-production"))
{
  $WorkItemTag = 'Non-Production'
  Write-Output "##vso[task.setvariable variable=WorkItemTag;isOutput=true]$WorkItemTag"
  #Save Work Item Tag as Stage Output Variable
  Write-Output "##vso[task.setvariable variable=WorkItemTag;isOutput=true]$WorkItemTag"
}
elseif($WorkItemTag.contains("production"))
{
  $WorkItemTag = 'Production'
  Write-Output "##vso[task.setvariable variable=WorkItemTag;isOutput=true]$WorkItemTag"
  #Save Work Item Tag as Stage Output Variable
  Write-Output "##vso[task.setvariable variable=WorkItemTag;isOutput=true]$WorkItemTag"
}
