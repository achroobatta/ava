[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)] [string] $locationPrefix,
	[Parameter(Mandatory=$true)] [string] $environmentPrefix
)
#This is useful when you want to refer to the script's directory path.
#$ScriptDir=Split-Path $MyInvocation.MyCommand.Path

"Original `$ErrorActionPreference='$($ErrorActionPreference)'"
$ErrorActionPreference="Stop"
"New `$ErrorActionPreference='$($ErrorActionPreference)'"

$allowedLocationPrefixes=@('edc', 'sdc')
$allowedEnvironmentPrefixes=@('prd', 'np')

if ($allowedLocationPrefixes -notcontains $locationPrefix)
{
	Write-Error "Location Prefix '$locationPrefix' is not supported. Allowed Location Prefixes: '$allowedLocationPrefixes'"
	Exit 1
}
if ($allowedEnvironmentPrefixes -notcontains $environmentPrefix)
{
	Write-Error "Environment Prefix '$environmentPrefix' is not supported. Allowed Environment Prefixes: '$allowedEnvironmentPrefixes'"
	Exit 1
}

$locationPrefix
$file = "scheduledQueryRules-$locationPrefix.param.$environmentPrefix.json"
$templateFile = "parametersTemplate.json"
$importFile = "logAlerts-$locationPrefix.$environmentPrefix.csv"

$template = get-content -raw -path $templateFile | ConvertFrom-Json
$scheduledQueryRules= import-csv $importFile

$template.parameters.scheduledQueryRulesObject.value.scheduledQueryRules = $scheduledQueryRules
$output = $template | ConvertTo-Json -Depth 10 | foreach-object { [System.Text.RegularExpressions.Regex]::Unescape($_) }

out-file -force $file -InputObject $output -Encoding utf8

