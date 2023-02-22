[CmdletBinding()]
param (
    [string]$SERVERURL,
    [string]$AdoOrgAgentRegistrationPAT,
    [string]$PoolName,
    [string]$AgentName
)

"Original `$ErrorActionPreference='$($ErrorActionPreference)'"
$ErrorActionPreference="Stop"
"New `$ErrorActionPreference='$($ErrorActionPreference)'"

# Work folder
$workFolderName     = '_work'   #Default : "_work"

#runnFolderPath - also is the download destination
$agentFolderPath    = 'C:\agent'

Start-Transcript
#Write-Host "start"

#test if an old installation exists, if so, delete the folder
if (test-path "$agentFolderPath")
{
    if (Get-Service "vstsagent*")
    {
        set-location "$agentFolderPath"
        .\config.cmd remove --unattended --auth pat --token $AdoOrgAgentRegistrationPAT
    }
}
else
{
	new-item -ItemType Directory -Force -Path "$agentFolderPath"
}

#get the latest build agent version
$wr = Invoke-WebRequest https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest -UseBasicParsing
$tag = ($wr | ConvertFrom-Json)[0].tag_name
$tag = $tag.Substring(1)

#installation file details
$installFile="vsts-agent-win-x64-$tag.zip"

# the latest version is not currently being used - install the latest
if (!(test-path "$agentFolderPath\$installFile"))
{
	set-location "C:\"
	Remove-Item -Path "$agentFolderPath" -Force -Confirm:$false -Recurse
	#create a new folder
	new-item -ItemType Directory -Force -Path "$agentFolderPath"
	set-location "$agentFolderPath"
	#write-host "$tag is the latest version"
	#build the url
	$download = "https://vstsagentpackage.azureedge.net/agent/$tag/$installFile"

	#download the agent
	Invoke-WebRequest $download -Out "$installFile"

	#expand the zip
	Expand-Archive -Path "$installFile" -DestinationPath $PWD
}

set-location "$agentFolderPath"

#run the config script of the build agent
.\config.cmd --unattended --url "$SERVERURL" --auth pat --token "$AdoOrgAgentRegistrationPAT" --pool "$PoolName" --agent "$AgentName" --acceptTeeEula --runAsService --work "$workFolderName"

#exit
Stop-Transcript
exit 0