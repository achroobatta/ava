[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)] [string] $templateBasePath
	#,
	#[bool] $doCommit = $false
)
#This is useful when you want to refer to the script's directory path.
#$ScriptDir=Split-Path $MyInvocation.MyCommand.Path

"Original `$ErrorActionPreference='$($ErrorActionPreference)'"
$ErrorActionPreference="Stop"
"New `$ErrorActionPreference='$($ErrorActionPreference)'"

"Parameters:"
"`$templateBasePath='$($templateBasePath)'"
# "`$doCommit='$($doCommit)'"

#parameter hygiene
$templateBasePath=$templateBasePath.Trim("\").Trim("/")

$azCliVersionTable=az --version
$azCliVersionTable

$azBicepVersionTable=az bicep version
$azBicepVersionTable

$templateBasePathObject=Get-Item -Path $templateBasePath
if ($null -eq $templateBasePathObject)
{
	Write-Error "No directory/file at: $templateBasePath"
	Exit 1
}
if ($templateBasePathObject.Attributes -ne "Directory")
{
	Write-Error "Not a directory: $templateBasePath"
	Exit 1
}

$generatedArmBasePath=($templateBasePathObject).PSParentPath.Replace("Microsoft.PowerShell.Core\FileSystem::", "") + "/arm-generated"

#"#######################################################################################"
"`$templateBasePath='$templateBasePath'"
"`$generatedArmBasePath='$generatedArmBasePath'"

"Removing '$generatedArmBasePath' if already exists"
if (Test-Path -Path "$generatedArmBasePath")
{
	Remove-Item -Recurse -Force -Path "$generatedArmBasePath"
}
"Creating directory '$generatedArmBasePath'"
New-Item -Force -Type Directory "$generatedArmBasePath"
"Copying '$templateBasePath/*' => '$generatedArmBasePath'"
Copy-Item -Recurse -Force -Path "$templateBasePath/*" -Destination "$generatedArmBasePath"

"Compiling bicep -> arm into folder '$generatedArmBasePath'"

$bicepFiles=(Get-ChildItem -Path "$generatedArmBasePath" -File -Filter *.bicep -Recurse)

if (($null -ne $bicepFiles) -and ($bicepFiles.Length -gt 0))
{
	foreach ($bicepFile in $bicepFiles)
	{
		"Build bicep file $($bicepFile.FullName)."
		#compile into same directory as the bicep file
		az bicep build --file $bicepFile.FullName
		$BicepBuildLastExitCode=$lastexitcode
		if ($BicepBuildLastExitCode -ne 0) {
			Write-Error "Bicep build failed for $($bicepFile.FullName)."
			Exit 1
		}
	}
	"Finished - Compiling bicep"
}
else
{
	Write-Error "No bicep files compiled - ARM code linting will run on zero ARM files and simply pass (undesireable)."
	Exit 1
}

"Cleanup - Remove any files not matching *.json"
Get-ChildItem -Path "$generatedArmBasePath" -File -Exclude *.json -Recurse| ForEach-Object {
	Remove-Item -Force -Path "$($_.FullName)" -Verbose
}

## committing only required
#if ($doCommit)
#{
#	git status
#	git pull
#	if (!(git status ./CFS.VirtualDataCentre/arm-generated/|Select-String -Pattern "nothing to commit, working tree clean"))
#	{
#		git config user.name github-actions
#		git config user.email github-actions@github.com
#		#always revert README.md (must revert it before running "git add --all ...")
#		git checkout -- ./CFS.VirtualDataCentre/arm-generated/README.md
#		git add --all ./CFS.VirtualDataCentre/arm-generated/*
#		#run git status for diagnostic purposes
#		git status
#		git commit -m 'auto-generated ARM from bicep'
#		git push -v origin
#	}
#}

##arm-ttk needs a azuredeploy.json or mainTemplate.json file in the directory (even if it's blank)
#if ((-Not (Test-Path -Path "$generatedArmBasePath/azuredeploy.json")) -And (-Not (Test-Path -Path "$generatedArmBasePath/mainTemplate.json")))
#{
#	"Writing to $generatedArmBasePath/azuredeploy.json"
#	'{"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#", "resources": []}//auto-generated empty azuredeploy.json file' | Out-File -FilePath "$generatedArmBasePath/azuredeploy.json"
#}

#end
