<#
.SYNOPSIS
  Update work item state and add comment
.DESCRIPTION
  This script will be used to update a work item state and add a new comment to it.

.NOTES
  Version:        1.0
  Author:         Abaigail Rose Artagame
  Creation Date:  29/11/2022
  Purpose/Change: Initial script development


#>


#-----------------------------------------------------------[Declarations]------------------------------------------------------------
param(
  $WorkItemId,
  $PAT,
  $WorkItemState,
  $WorkItemComment,
  $Processed,
  $Tag,
  $UpdateState,
  $UpdateComment
)


#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Set_WorkItemState{
  <#
        .SYNOPSIS
        Updates work item state.

        .DESCRIPTION
        Updates work item state.

        .PARAMETER WorkItemId
        ID of the Work Item to be updated.

        .PARAMETER PAT
        Personal Access Token used for Authentication.

        .PARAMETER WorkItemState
        New Work Item State
    #>
  Param(

    $WorkItemId,
    $PAT,
    $WorkItemState

  )
  Begin{
    Write-Information -MessageData "Updating Work Item $WorkItemId..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $updateWorkItemApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)_apis/wit/workitems/$WorkItemId" + "?api-version=7.1-preview.3"
      Write-Information -MessageData $updateWorkItemApi -InformationAction Continue
      $updateWorkItemReqBod = '
      [
        {
          "op": "add",
          "path": "/fields/System.State",
          "value": "--WORKITEMSTATE--"
        }
      ]'

      $updateWorkItemReqBod = $updateWorkItemReqBod.Replace("--WORKITEMSTATE--", $WorkItemState)
      Write-Information -MessageData $updateWorkItemReqBod -InformationAction Continue

      Invoke-RestMethod -Uri $updateWorkItemApi -Method Patch -Headers $header -Body $updateWorkItemReqBod -ContentType 'application/json-patch+json' -ErrorAction Stop

      return $true

    }
    Catch
    {
      return $false
    }
  }
  End{}
}
Function Add_WorkItemComment{
  <#
        .SYNOPSIS
        Add a new comment to a work item.

        .DESCRIPTION
        Add a new comment to a work item.

        .PARAMETER WorkItemId
        ID of the Work Item to be updated.

        .PARAMETER PAT
        Personal Access Token used for Authentication.

        .PARAMETER WorItemComment
        New Work Item Comment

    #>
  Param(

    $WorkItemId,
    $PAT,
    $WorItemComment

  )
  Begin{
    Write-Information -MessageData "Updating Work Item $WorkItemId..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $addWorkItemCommentApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$env:SYSTEM_TEAMPROJECTID/_apis/wit/workItems/$WorkItemId" + "/comments?api-version=7.0-preview.3"
      Write-Information -MessageData $addWorkItemCommentApi -InformationAction Continue

      $addWorkItemCommentReqBod = '
        {
          "text": "--WORKITEMCOMMENT--"
        }'

      $addWorkItemCommentReqBod = $addWorkItemCommentReqBod.Replace("--WORKITEMCOMMENT--", $WorItemComment)
      Write-Information -MessageData $addWorkItemCommentReqBod -InformationAction Continue

      Invoke-RestMethod -Uri $addWorkItemCommentApi -Method Post -Headers $header -Body $addWorkItemCommentReqBod -ContentType 'application/json' -ErrorAction Stop

      return $true

    }
    Catch
    {
      return $false
    }
  }
  End{}
}
Function Replace_WorkItemTag{
  <#
        .SYNOPSIS
        Updates work item state.

        .DESCRIPTION
        Updates work item state.

        .PARAMETER WorkItemId
        ID of the Work Item to be updated.

        .PARAMETER PAT
        Personal Access Token used for Authentication.
    #>
  Param(

    $WorkItemId,
    $PAT,
    $Tag
  )
  Begin{
    Write-Information -MessageData "Updating Work Item $WorkItemId..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $updateWorkItemApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)_apis/wit/workitems/$WorkItemId" + "?api-version=7.1-preview.3"
      Write-Information -MessageData $updateWorkItemApi -InformationAction Continue
      $updateWorkItemReqBod = '
      [
        {
          "op": "replace",
          "path": "/fields/System.Tags",
          "value": "--TAG--"
        }
      ]'

      $updateWorkItemReqBod = $updateWorkItemReqBod.Replace("--TAG--", $Tag)

      Write-Information -MessageData $updateWorkItemReqBod -InformationAction Continue

      Invoke-RestMethod -Uri $updateWorkItemApi -Method Patch -Headers $header -Body $updateWorkItemReqBod -ContentType 'application/json-patch+json' -ErrorAction Stop

      return $true

    }
    Catch
    {
      return $false
    }
  }
  End{}
}
Function Add_WorkItemTag{
  <#
        .SYNOPSIS
        Updates work item state.

        .DESCRIPTION
        Updates work item state.

        .PARAMETER WorkItemId
        ID of the Work Item to be updated.

        .PARAMETER PAT
        Personal Access Token used for Authentication.
    #>
  Param(

    $WorkItemId,
    $PAT,
    $Tag
  )
  Begin{
    Write-Information -MessageData "Updating Work Item $WorkItemId..." -InformationAction Continue
  }
  Process
  {
    Try{

      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $updateWorkItemApi = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)_apis/wit/workitems/$WorkItemId" + "?api-version=7.1-preview.3"
      Write-Information -MessageData $updateWorkItemApi -InformationAction Continue
      $updateWorkItemReqBod = '
      [
        {
          "op": "add",
          "path": "/fields/System.Tags",
          "value": "--TAG--"
        }
      ]'

      $updateWorkItemReqBod = $updateWorkItemReqBod.Replace("--TAG--", $Tag)

      Write-Information -MessageData $updateWorkItemReqBod -InformationAction Continue

      Invoke-RestMethod -Uri $updateWorkItemApi -Method Patch -Headers $header -Body $updateWorkItemReqBod -ContentType 'application/json-patch+json' -ErrorAction Stop

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

Write-Information -MessageData $Processed -InformationAction Continue

#Set Work Item Tag Processed
if($Processed -eq 'false')
{
  $UpdateWorkItemTag = Add_WorkItemTag -WorkItemId $WorkItemId -PAT $PAT -Tag "no attachment"
  if($UpdateWorkItemTag -contains $false)
  {
    Write-Error "There is an error in updating the work item tag."
  }
  elseif($UpdateWorkItemTag -contains $true)
  {
    Write-Information -MessageData "Updating work item tag for $WorkItemId is successful" -InformationAction Continue
  }

}
elseif($Processed -eq 'true')
{
  if($Tag -eq "Non-Production")
  {
    $Tag = 'request: non-production;processed'
  }
  elseif($Tag -eq "Production")
  {
    $Tag = 'request: production;processed'
  }
  $ReplaceWorkItemTag = Replace_WorkItemTag -WorkItemId $WorkItemId -PAT $PAT -Tag $Tag
  if($ReplaceWorkItemTag -contains $false)
  {
    Write-Error "There is an error in updating the work item tag."
  }
  elseif($ReplaceWorkItemTag -contains $true)
  {
    Write-Information -MessageData "Updating work item tag for $WorkItemId is successful" -InformationAction Continue
  }

}
if($UpdateState -ne 'false')
{
  #Call Update-WorkItemState
  #Change Task State
  $UpdateWorkItemState = Set_WorkItemState -WorkItemId $WorkItemId -PAT $PAT -WorkItemState $WorkItemState
  if($UpdateWorkItemState -contains $false)
  {
    Write-Error "There is an error in updating the work item state."
  }
  elseif($UpdateWorkItemState -contains $true)
  {
    Write-Information -MessageData "Updating work item state for $WorkItemId is successful" -InformationAction Continue
  }
}
if($UpdateComment -ne 'false')
{
  #Call Add-WorkItemComment
  #Add Comments to Task
  $addWorkItemComment = Add_WorkItemComment -WorkItemId $WorkItemId -PAT $PAT -WorItemComment $WorkItemComment
  if($addWorkItemComment -contains $false)
  {
    Write-Error "There is an error in adding a new the work item comment."
  }
  elseif($UpdateWorkItemState -contains $true)
  {
    Write-Information -MessageData "Added work item comment for $WorkItemId is successful." -InformationAction Continue
  }
}
