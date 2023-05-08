#create by: Joshua Ira San Ramon
param
(
    [Parameter(Mandatory=$true)]
    $WorkItemComment,
    [Parameter(Mandatory=$true)]
    [String]$keyVaultNameforSecret,
    [Parameter(Mandatory=$true)]
    [int]$taskNumber,
    [Parameter(Mandatory=$true)]
    [string]$subId,
    [Parameter(Mandatory=$true)]
    [string]$subTenantId
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
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Logging in Devops") >> $logFilePath
      $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

      $header = @{authorization = "Basic $token"}
      $addWorkItemCommentApi = "$($url)$project/_apis/wit/workItems/$taskNumber" + "/comments?api-version=7.0-preview.3"

      $addWorkItemCommentReqBod = '
        {
          "text": "--WORKITEMCOMMENT--"
        }'

      $addWorkItemCommentReqBod = $addWorkItemCommentReqBod.Replace("--WORKITEMCOMMENT--", $WorkItemComment)
      $output = Invoke-RestMethod -Uri $addWorkItemCommentApi -Method Post -Headers $header -Body $addWorkItemCommentReqBod -ContentType 'application/json' -ErrorAction Stop
      if($null -ne $output)
      {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Successfully Logged to Task: $taskNumber") >> $logFilePath
        return "Successfully Logged to Task: $taskNumber"
      }
    }
    Catch
    {
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Failed Logged to Task: $taskNumber") >> $logFilePath
      return "Failed to Log to Task: $taskNumber"
    }
}
Set-Item -path WSMan:\localhost\Shell\IdleTimeout -Value '2147483647'
$logFilePath = "$PSScriptRoot\logging_LoggingDevOps.txt"
Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath

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
Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing Fuction..") >> $logFilePath
Add_WorkItemComment -taskNumber $taskNumber -PAT $PAT -WorkItemComment $WorkItemComment -ftsBaseURL $ftsBaseURL -getproject $getproject -keyVaultNameforSecret $keyVaultNameforSecret -url $url -project $project
Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath