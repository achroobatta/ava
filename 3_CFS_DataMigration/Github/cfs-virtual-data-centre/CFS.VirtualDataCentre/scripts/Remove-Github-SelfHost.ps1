[CmdletBinding()]
param (
    [string]$GitHubOrgRunnerRegistrationPAT,
    [string]$OrgURL
)

$agentFolderPath    = 'C:\agent'

set-location "$agentFolderPath"

#Creating newURL for api.github.com
$apiURL = $OrgURL -replace "https://github.com/", "https://api.github.com/orgs/"

#retrieve registration token
$runnerRegistrationToken=((Invoke-WebRequest -Method 'POST' -H @{ "Authorization" = "token $GitHubOrgRunnerRegistrationPAT" } -Uri "$apiURL/actions/runners/registration-token" -UseBasicParsing).Content | ConvertFrom-Json).token

.\config.cmd remove --unattended --token $runnerRegistrationToken