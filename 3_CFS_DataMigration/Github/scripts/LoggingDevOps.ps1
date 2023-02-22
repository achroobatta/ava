param
(
    [Parameter(Mandatory=$false)]
    [String]$orgURL = "https://dev.azure.com/AUSUP",
    [Parameter(Mandatory=$false)]
    [int]$WorkItemId = 385,
    [Parameter(Mandatory=$false)]
    [string]$PAT = "xa6u76lqjcblfthindkczv5olev3iefprswk2tll2z2jkgaxgeva",
    [Parameter(Mandatory=$false)]
    [string]$WorkItemComment = "Message: test message \r Powershell Script: powershell.ps1",
    [Parameter(Mandatory=$false)]
    [string]$coreAreaID = "1d4f49f9-02b9-4e26-b826-2cdb6195f2a9",
    [Parameter(Mandatory=$false)]
    [string]$projectname = "core-it"
)

function GetURL()
{
    param
    (
        $orgURL,
        $areaID
    )

    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
    $header = @{authorization = "Basic $token"}

    $orgResourceURL = [string]::Format("{0}/_apis/resourceAreas/{1}?api-preview=5.0-preview.1", $orgURL, $areaID)
    $result = Invoke-RestMethod -Uri $orgResourceURL -Headers $header

    if ("null" -eq $result)
    {
        $areaURL = $orgURL
    }
    else
    {
        $areaURL = $result.locationUrl
    }

    return $areaURL
}

function getProjectName()
{
    param
    (
        $ftsBaseURL,
        $projectname
    )
    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
    $header = @{authorization = "Basic $token"}

    $projectURL = "$($ftsBaseURL)_apis/projects?api-version=5.0"
    $proj = Invoke-RestMethod -Uri $projectURL -Method Get -ContentType 'application/json' -Headers $header
    $lists = $proj.value

    foreach($list in $lists)
    {
        if($list.name -eq $projectname)
        {
            return $list.name
        }
    }
}

Function Add_WorkItemComment(){
  Param
  (
    $WorkItemId,
    $PAT,
    $WorkItemComment,
    $ftsBaseURL,
    $getproject
  )
  Try{
      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}

      $addWorkItemCommentApi = "$($ftsBaseURL)$getproject/_apis/wit/workItems/$WorkItemId" + "/comments?api-version=7.0-preview.3"

      $addWorkItemCommentReqBod = '
        {
          "text": "--WORKITEMCOMMENT--"
        }'

      $addWorkItemCommentReqBod = $addWorkItemCommentReqBod.Replace("--WORKITEMCOMMENT--", $WorkItemComment)

      Invoke-RestMethod -Uri $addWorkItemCommentApi -Method Post -Headers $header -Body $addWorkItemCommentReqBod -ContentType 'application/json' -ErrorAction Stop

      return $true

    }
    Catch
    {
      return $false
    }
}

$ftsBaseURL = GetURL -orgURL $orgURL -areaID $coreAreaID
$getproject = getProjectName -ftsBaseURL $ftsBaseURL -projectname $projectname
Add_WorkItemComment -WorkItemId $WorkItemId -PAT $PAT -WorkItemComment $WorkItemComment -ftsBaseURL $ftsBaseURL -getproject $getproject