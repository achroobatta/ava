<#
.SYNOPSIS
  Check if work item state
.DESCRIPTION
  This script will be used to check for the task state

.NOTES
  Version:        1.0
  Author:         Abaigail Rose Artagame
  Creation Date:  23/01/2023
  Purpose/Change: Initial script development


#>


#-----------------------------------------------------------[Declarations]------------------------------------------------------------
param(
  $NonProdSubIdCreation,
  $NonProdSubIdUpdate,
  $ProdSubIdCreation,
  $ProdSubIdUpdate,
  $PAT
)


#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Get_PipelineRuns{
  <#
        .SYNOPSIS
        Returns the latest subscription run id.

        .DESCRIPTION
        Returns the latest subscription run id.

        .PARAMETER TriggerPipelineId
        Trigger Pipeline Id

        .PARAMETER PAT
        Personal Access Token used for Authentication.

    #>
  Param(

    $TriggerPipelineId,
    $PAT

  )
  Begin{
    Write-Information -MessageData "Listing pipeline runs for Trigger Pipeline..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $getPipelineRunsApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/pipelines/" + $TriggerPipelineId + "/runs?api-version=7.0"



      $getPipelineRuns = Invoke-RestMethod -Uri $getPipelineRunsApi -Method Get -Headers $header -ErrorAction Stop
      $inProgressPipelineRuns = $getPipelineRuns.value | Where-Object {$_.state -eq 'inProgress'} | Sort-Object -Descending -Property 'id'

      return $inProgressPipelineRuns

    }
    Catch
    {
      return $null
    }
  }
  End{}
}
Function Get_RunId{
  <#
        .SYNOPSIS
        Returns the latest subscription run id.

        .DESCRIPTION
        Returns the latest subscription run id.

        .PARAMETER NonProdSubIdCreation
        Id of the Service Hook Subscription for Non Prod Work Item Creation.
        .PARAMETER NonProdSubIdUpdate
        Id of the Service Hook Subscription for Non Prod Work Item Update.
        .PARAMETER ProdSubIdCreation
        Id of the Service Hook Subscription for Prod Work Item Creation.
        .PARAMETER ProdSubIdUpdate
        Id of the Service Hook Subscription for Prod Work Item Update.

        .PARAMETER PAT
        Personal Access Token used for Authentication.

    #>
  Param(

    $NonProdSubIdCreation,
    $NonProdSubIdUpdate,
    $ProdSubIdCreation,
    $ProdSubIdUpdate,
    $PAT

  )
  Begin{
    Write-Information -MessageData "Getting run history for id" -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $getRunHistoryApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)_apis/hooks/notificationsquery?api-version=7.1-preview.1"

      $getRunHistoryReqBod = '
      {
          "subscriptionIds": ["--NonProdSubIdCreation--","--NonProdSubIdUpdate--","--ProdSubIdCreation--","--ProdSubIdUpdate--"]
      }'

      $getRunHistoryReqBod = $getRunHistoryReqBod.Replace("--NonProdSubIdCreation--", $NonProdSubIdCreation)
      $getRunHistoryReqBod = $getRunHistoryReqBod.Replace("--NonProdSubIdUpdate--", $NonProdSubIdUpdate)
      $getRunHistoryReqBod = $getRunHistoryReqBod.Replace("--ProdSubIdCreation--", $ProdSubIdCreation)
      $getRunHistoryReqBod = $getRunHistoryReqBod.Replace("--ProdSubIdUpdate--", $ProdSubIdUpdate)
      $getRunHistory = Invoke-RestMethod -Uri $getRunHistoryApi -Method Post -Headers $header -Body $getRunHistoryReqBod -ContentType 'application/json' -ErrorAction Stop

      return $getRunHistory

    }
    Catch
    {
      return $null
    }
  }
  End{}
}
Function Get_WorkItemId{
  <#
        .SYNOPSIS
        Returns the work item id that triggered the service hook.

        .DESCRIPTION
        Returns the work item id that triggered the service hook.

        .PARAMETER SubsriptionId
        Id of the Service Hook Subscription.

        .PARAMETER RunId
        Id of the latest Service Hook Subscription Run.

        .PARAMETER PAT
        Personal Access Token used for Authentication.
    #>
  Param(

    $SubscriptionId,
    $RunId,
    $PAT

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

      $getWorkItemIdApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)_apis/hooks/subscriptions/$SubscriptionId/notifications/$RunId" + "?api-version=7.1-preview.1"
      $getworkItemId = Invoke-RestMethod -Uri $getWorkItemIdApi -Method Get -Headers $header -ErrorAction Stop
      if($getworkItemId.details.eventType -eq 'workitem.created')
      {
        return $getworkItemId.details.event.resource.id
      }
      elseif($getworkItemId.details.eventType -eq 'workitem.updated')
      {
        return $getworkItemId.details.event.resource.workItemId
      }
    }
    Catch
    {
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
      if($getworkItemId.fields.'System.Tags'.contains("non-production"))
      {
        return 'Non-Production'
      }
      elseif ($getworkItemId.fields.'System.Tags'.contains("production"))
      {
        return 'Production'
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
#Call Get_RunId Function
$Run = Get_RunId -NonProdSubIdCreation $NonProdSubIdCreation -NonProdSubIdUpdate $NonProdSubIdUpdate -ProdSubIdCreation $ProdSubIdCreation -ProdSubIdUpdate $ProdSubIdUpdate -PAT $PAT
if($null -eq $Run)
{
  Write-Error "There is an error in getting the service hook subscription latest run id."
}

$SubId = $Run.results[0].subscriptionId
$RunId = $Run.results[0].id
#Call Get_WorkItemId Function
$WorkItemId = Get_WorkItemId -SubscriptionId $SubId -RunId $RunId -PAT $PAT
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
if($null -eq $WorkItemTag)
{
  Write-Error "There is an error in getting the work item tag."
}
#Save Work Item Tag as Stage Output Variable
Write-Output "##vso[task.setvariable variable=WorkItemTag;isOutput=true]$WorkItemTag"
