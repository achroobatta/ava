<#
This script can can on a Windows server with Powershell 3.0 and above and the IIS Administration Module
It scans the IIS metadata to read all web.config files and detect the presence of secret/password in clear text
It does this by extracting all appSettings and connectionStrings and comparing key and or values with known patterns
of password.
A web.config is flagged from the moment
	- an  appSettings key either matches 'pwd|pass|key$|secret$'
	- an appSettings value or connectionString value matches 'password=|pwd=|key='

Outputs a hashtable with the following:
	@{
		IisMetadata=@{
			Sites=[]@{Name=string; PhysicalPath=string}
			Applications=[]@{Path=string, Site=string, ApplicationPool=string, PhysicalPath=string}
			ApplicationPools=[]@{Name=string, IdentityType=string, UserName=string}
		}
		WebConfigInfos=[]@{
			Path=string
			AppSettingsKeys=[]string
			ConnectionStringNames=[]string
			FlaggedAppSettingsKeys=[]string
			FlaggedConnectionStrings=[]string
			IsFlagged=bool
			FlaggedBackups=[]string
			HasFlaggedBackups=[]string
		}
		IsFlagged=bool
		HasFlaggedBackups=bool
		Logs=string
		Error=string
	}

# Logs are returned as part of the standard output because this script is meant
# to run remotely and Verbose streams can't seem to possibly be redirected
# See https://github.com/PowerShell/PowerShell/issues/13562

# For consistency, Errors are also returned in the standard output in a property

# Note that Errors are still being written to the Error stream
# and that running the script in Verbose mode will also send the logs to the Verbose stream
#>

[cmdletbinding()]
param()

$logs = @()

function Log {
	<#
	.DESCRIPTION
	Log content in both Verbose stream and appends logs into a the $logs Script variable

	.PARAMETER InputObject
	InputObject The content to log

	.EXAMPLE
	Log "This is a log"
	"This is a log" | Log

	.NOTES
	This is to workaround a limitation where verbose streams cannot
	be redirected when running a command remotely (See https://github.com/PowerShell/PowerShell/issues/13562)
	Instead, the approach is to keep logs in a variable so they can be sent later
	#>
	param(
        [Parameter(ValueFromPipeline = $true)]$InputObject
    )
    process {
		$Script:logs += $InputObject
		Write-Verbose $InputObject
	 }
}

try {
	$psMajorVersion = $PSVersionTable.PSVersion.Major

	if ($psMajorVersion -lt 3) {
		Write-Warning "The script detected Powershell v$psMajorVersion"
		Write-Warning "The minimum supported Powershell version is 3"
		throw "Powershell v$psMajorVersion is not supported"
	}

	try {
		Add-PSSnapin WebAdministration -ErrorAction Stop
	} catch {
		try {
			 Import-Module WebAdministration -ErrorAction Stop
			} catch {
				Write-Warning "Failed to load the WebAdministration module. This is usually resolved by doing one of the following:"
				Write-Warning "1. Install IIS via Add Roles and Features, Web Server (IIS)"
				Write-Warning "2. Install .NET Framework 3.5.1"
				Write-Warning "3. Upgrade to PowerShell 3.0 (or greater)"
				Write-Warning "4. On Windows 2008 you might need to install PowerShell SnapIn for IIS from http://www.iis.net/downloads/microsoft/powershell#additionalDownloads"
				throw ($error | Select-Object -First 1)
		}
	}

	$iisMeta = @{
		Sites = @(Get-WebSite | ForEach-Object { @{ Name=$_.Name;PhysicalPath=$_.PhysicalPath }})
		Applications = @(Get-WebSite | ForEach-Object { $site=$_; Get-WebApplication -Site $_.Name | ForEach-Object { @{Path=$_.Path;PhysicalPath=$_.PhysicalPath;ApplicationPool=$_.ApplicationPool;Site=$site.Name} } })
		ApplicationPools = @(Get-ChildItem "IIS:\apppools" | ForEach-Object { @{Name=$_.Name; IdentityType=$_.processModel.identityType; UserName=$_.processModel.userName } })
	}

	Log "Found $($iisMeta.Sites.Count) sites"
	Log "Found $($iisMeta.Applications.Count) applications"
	Log "Found $($iisMeta.ApplicationPools.Count) application pools"

	$physicalPaths = ($iisMeta.Sites + $iisMeta.Applications) | ForEach-Object { $_.PhysicalPath } | Select-Object -Unique

	<#
	.DESCRIPTION
	Accepts a directory path and search for what ressembles backup of Config file and returns their full path

	.PARAMETER Path
	Path the directory path where the web.config backup files can be present

	.EXAMPLE
	FindBackups "c:\\inetpub\wwwRoot\MyApp"
	Would return "@("c:\\inetpub\wwwRoot\MyApp\web.config.bak","c:\\inetpub\wwwRoot\MyApp\Copy of web.config")

	.NOTES
	It doesn't return the web.config and looks for any file that matches *web*.config*
	#>
	function FindBackups {
		param([Parameter(Mandatory=$true)][string]$Path)

		Get-ChildItem -Path (Join-Path -Path $Path -ChildPath "/*") -File -Include '*web*.config*' -Exclude "web.config" | ForEach-Object { Join-Path -Path $Path -ChildPath $_.Name }
	}

	function AnalyseWebConfig {
		<#
		.DESCRIPTION
		Parses the web.config file and outputs the following
		@{
			Path= the path from the input
			AppSettingsKeys= all the appSettings keys
			ConnectionStringNames = all the connection string names
			FlaggedAppSettingsKeys = all the appSettings keys where the key or value matches what ressembles a secret
			FlaggedConnectionStrings = all the connection string names where the value matches what ressembles a secret
			IsFlagged = true when at least one app settings key/value or one connection string ressembles a secret
		}

		.PARAMETER Path
		The Path to the config file

		.NOTES
		Secrets are determined by known key and value patterns.
		#>
		param(
			[Parameter(Mandatory=$true)][string]$Path
		)

		# regex pattern to match an application key that ressembles a secret
		$secretKeyPattern = 'pwd|pass|key$|secret$'
		# regex pattern to match a connectionString or appSettings value that ressembles a secret
		$secretValuePattern = 'password=|pwd=|key='

		Log "Start analysis of $Path"

		[XML] $configXml = Get-Content -Path $Path -ErrorAction Continue

		if (-not $configXml) {
			Write-Warning "Error trying to parse $Path as XML"
		}
		else {
			$appSettings = $configXml.SelectNodes('//appSettings/add')
			$connectionStrings = $configXml.SelectNodes('//connectionStrings/add')

			$appKeys = @($appSettings | ForEach-Object { $_.Attributes['key'].Value })
			$flaggedAppKeys = @($appSettings | Where-Object { $_.Attributes['key'].Value -match $secretKeyPattern -or $_.Attributes['value'].Value -match $secretValuePattern } | ForEach-Object { $_.Attributes['key'].Value })

			$connectionStringNames = @($connectionStrings | ForEach-Object { $_.Attributes['name'].Value })
			$flaggedConnectionStrings = @($connectionStrings | Where-Object { $_.Attributes['connectionString'].Value -match $secretValuePattern } | ForEach-Object { $_.Attributes['name'].Value })

			$isFlagged = (@($flaggedAppKeys).Count -gt 0 -or @($flaggedConnectionStrings).Count -gt 0)
		}

		@{
			Path=$Path
			AppSettingsKeys=$appKeys
			ConnectionStringNames=$connectionStringNames
			FlaggedAppSettingsKeys=$flaggedAppKeys
			FlaggedConnectionStrings=$flaggedConnectionStrings
			IsFlagged=$isFlagged
		}

		Log "Completed analysis of $Path"

	}

	function AnalysePhysicalPath {
		param(
			# Path to web.config directory
			[Parameter(Mandatory=$true)][string]$Path
		)

		Log "Start analysis of physical path $Path"

		$webConfigPath = Join-Path -Path $_ -ChildPath 'web.config'
		$backupPaths = @(FindBackups -Path $Path)

		Log "Found $($backupPaths.Count) web.config backups in $Path"

		$webConfigResult = AnalyseWebConfig $webConfigPath
		$backupResults = $backupPaths | ForEach-Object { AnalyseWebConfig -Path $_ }

		$webConfigResult.FlaggedBackups = @($backupResults | Where-Object { $_.IsFlagged } | ForEach-Object { [System.IO.Path]::GetFileName($_.Path) })
		$webConfigResult.HasFlaggedBackups = $webConfigResult.FlaggedBackups.Count -gt 0
		$webConfigResult

		Log "Completed analysis of physical path $Path"
	}

	$physicalPathsWithConfig = $physicalPaths | Where-Object { Test-Path (Join-Path -Path $_ -ChildPath 'web.config') }
	$configInfos = @($physicalPathsWithConfig | ForEach-Object { AnalysePhysicalPath -Path $_ })
}
catch {
	$lastError = $error | Select-Object -First 1
	Write-Error $lastError

	$errorMessage = $lastError.Exception.Message
}

@{
	IisMetadata = $iisMeta
	PhysicalPaths = $physicalPaths
	WebConfigInfos = $configInfos
	IsFlagged = (($configInfos | Where-Object { $_.IsFlagged }).Count -gt 0)
	HasFlaggedBackups = (($configInfos | Where-Object { $_.HasFlaggedBackups }).Count -gt 0)
	Logs=($logs -join "`n")
	Error=$errorMessage
}


