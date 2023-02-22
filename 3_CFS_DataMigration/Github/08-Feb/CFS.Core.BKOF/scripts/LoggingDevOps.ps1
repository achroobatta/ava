#create by: Joshua Ira San Ramon
param
(
    [Parameter(Mandatory=$true)]
    $WorkItemComment,
    [Parameter(Mandatory=$true)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [int]$taskNumber
)
function azconnect()
{
    Connect-AzAccount -identity -Force -SkipContextPopulation -ErrorAction Stop
}
Function Add_WorkItemComment(){
  Param
  (
    $taskNumber,
    $PAT,
    $WorkItemComment,
    $url,
    $project
  )
  Try{
      # Create header with PAT
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}
      $addWorkItemCommentApi = "$($url)$project/_apis/wit/workItems/$taskNumber" + "/comments?api-version=7.0-preview.3"

      $addWorkItemCommentReqBod = '
        {
          "text": "--WORKITEMCOMMENT--"
        }'

      $addWorkItemCommentReqBod = $addWorkItemCommentReqBod.Replace("--WORKITEMCOMMENT--", $WorkItemComment)
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      $output = Invoke-RestMethod -Uri $addWorkItemCommentApi -Method Post -Headers $header -Body $addWorkItemCommentReqBod -ContentType 'application/json' -ErrorAction Stop
      if($null -ne $output)
      {
        return "Successfully Logged to Task: $taskNumber"
      }
    }
    Catch
    {
      return "Failed to Log to Task: $taskNumber"
    }
}
azconnect | Out-Null
$url = "https://dev.azure.com/AUSUP/"
$project = "core-it"
$PAT = Get-AzKeyVaultSecret -VaultName $keyVaultNameforSecret -Name PAT -AsPlainText
Add_WorkItemComment -taskNumber $taskNumber -PAT $PAT -WorkItemComment $WorkItemComment -ftsBaseURL $ftsBaseURL -getproject $getproject -keyVaultNameforSecret $keyVaultNameforSecret -url $url -project $project