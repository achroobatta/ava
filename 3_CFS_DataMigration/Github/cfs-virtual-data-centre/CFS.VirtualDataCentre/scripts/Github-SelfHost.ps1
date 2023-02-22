[CmdletBinding()]
param (
    [string]$GitHubOrgRunnerRegistrationPAT,
    [string]$OrgURL,
    [string]$RunnerGroup,
    [string]$RunnerName
)

"Original `$ErrorActionPreference='$($ErrorActionPreference)'"
$ErrorActionPreference="Stop"
"New `$ErrorActionPreference='$($ErrorActionPreference)'"

# Work folder
$workFolderName     = '_work'               #Default : "_work"

#runnFolderPath - also is the download destination
$agentFolderPath   = 'C:\agent'



Start-Transcript
#Write-Host "start"

#Creating newURL for api.github.com
$apiURL = $OrgURL -replace "github.com", "api.github.com/orgs"

#retrieve registration token
$runnerRegistrationToken=((Invoke-WebRequest -Method 'POST' -H @{ "Authorization" = "token $GitHubOrgRunnerRegistrationPAT" } -Uri "$apiURL/actions/runners/registration-token" -UseBasicParsing).Content | ConvertFrom-Json).token

#test if an old installation exists, if so, delete the folder
if (test-path "$agentFolderPath")
{
    if (Get-Service "actions.runner.*")
    {
        #Stop-Service "actions.runner.*"
        set-location "$agentFolderPath"
        .\config.cmd remove --unattended --token $runnerRegistrationToken
    }
}
else
{
	new-item -ItemType Directory -Force -Path "$agentFolderPath"
}

#get the latest build agent version
$wr = Invoke-WebRequest https://api.github.com/repos/actions/runner/releases/latest -UseBasicParsing
$tag = ($wr | ConvertFrom-Json)[0].tag_name
$tag = $tag.Substring(1)

#installation file details
$installFile="actions-runner-win-x64-$tag.zip"

# the latest version is not currently being used - install the latest
if (!(test-path "$agentFolderPath\$installFile"))
{
	set-location "C:\"

	#delete folder
	Remove-Item -Path "$agentFolderPath" -Force -Confirm:$false -Recurse
	#create a new folder
	new-item -ItemType Directory -Force -Path "$agentFolderPath"
	set-location "$agentFolderPath"

	#write-host "$tag is the latest version"

	#build the url
	$download = "https://github.com/actions/runner/releases/download/v$tag/$installFile"

	#download the agent
	Invoke-WebRequest $download -Out $installFile

	#expand the zip
	Expand-Archive -Path $installFile -DestinationPath $PWD
}

set-location "$agentFolderPath"

#run the config script of the build agent
.\config.cmd --unattended --url "$OrgURL" --token "$runnerRegistrationToken" --runnergroup "$RunnerGroup" --name "$RunnerName" --runasservice --work "$workFolderName" --labels "$RunnerGroup"

#exit
Stop-Transcript
exit 0