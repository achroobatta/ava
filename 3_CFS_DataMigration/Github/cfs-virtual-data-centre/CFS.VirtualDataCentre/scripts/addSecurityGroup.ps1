[CmdletBinding()]
param (
	[Parameter(Mandatory=$true)] [string] $sgName,
	[string] $Description,
	[nullable[bool]] $SecurityEnabled,
	[nullable[bool]] $MailEnabled,
	[string] $MailNickName, #only takes effect if $MailEnabled=$True
	[nullable[bool]] $IsForManagementGroupRoleAssignment
)

#example usage
#$secGroups = Get-Content -Path .\sg-list.json | ConvertFrom-Json
#foreach ($sg in $secGroups) {
#  .\addSecurityGroup.ps1 `
#    -sgName $sg.name `
#    -Description $sg.description `
#    -SecurityEnabled $sg.securityEnabled `
#    -MailEnabled $sg.mailEnabled `
#    -MailNickName $sg.mailNickName `
#    -IsForManagementGroupRoleAssignment $sg.isForManagementGroupRoleAssignment
#}

Write-Debug "== original parameters =="
Write-Debug "`$sgName='$sgName'"
Write-Debug "`$Description='$Description'"
Write-Debug "`$SecurityEnabled='$SecurityEnabled'"
Write-Debug "`$MailEnabled='$MailEnabled'"
Write-Debug "`$MailNickName='$MailNickName'"
Write-Debug "`$IsForManagementGroupRoleAssignment='$IsForManagementGroupRoleAssignment'"

#default value for $SecurityEnabled
if ($null -eq $SecurityEnabled)
{
	$SecurityEnabled = $True
}

#default value for $MailEnabled
if ($null -eq $MailEnabled)
{
	$MailEnabled = $False
}

#default value for $MailNickName
if ($null -eq $MailNickName -Or "" -eq $MailNickName)
{
	$MailNickName = $sgName
}

#default value for $IsForManagementGroupRoleAssignment
if ($null -eq $IsForManagementGroupRoleAssignment)
{
	'`$IsForManagementGroupRoleAssignment is null'
	$IsForManagementGroupRoleAssignment = $False
}

if ($True -eq $IsForManagementGroupRoleAssignment)
{
	if($sgName.ToLower().Contains('iden'.ToLower())) {
		$group = 'Identity'
	}
	elseif($sgName.ToLower().Contains('sec'.ToLower())) {
		$group = 'Security'
	}
	elseif($sgName.ToLower().Contains('conn'.ToLower())) {
		$group = 'Connectivity'
	}
	elseif($sgName.ToLower().Contains('ops'.ToLower())) {
		$group = 'Operations'
	}
	elseif($sgName.ToLower().Contains('bkof'.ToLower())) {
		$group = 'Back Office'
	}
	elseif($sgName.ToLower().Contains('fwp'.ToLower())) {
		$group = 'CFS Wrap'
	}
	elseif($sgName.ToLower().Contains('fcp'.ToLower())) {
		$group = 'First Choice'
	}
	elseif($sgName.ToLower().Contains('CFSCoManagementGroup'.ToLower())) {
		$group = 'CFSCoManagementGroup'
	}
	else {
		$group = ''
		Write-Information "Please check the naming convention"
	}

	if($sgName.ToLower().Contains('owner'.ToLower())) {
		$permission = 'Owner'
	}
	elseif($sgName.ToLower().Contains('reader'.ToLower())) {
		$permission = 'Reader'
	}
	elseif($sgName.ToLower().Contains('contributor'.ToLower())) {
		$permission = 'Contributor'
	}
	else {
		$permission = ''
		Write-Information "Please check the naming convention"
	}

	if ($null -eq $Description -Or "" -eq $Description)
	{
		$Description = "Security Group for " + $group + " - " + $permission
	}
} else {
	if ($null -eq $Description -Or "" -eq $Description)
	{
		$Description = $sgName
	}
}


"== sanitised parameters =="
"`$sgName='$sgName'"
"`$Description='$Description'"
"`$SecurityEnabled='$SecurityEnabled'"
"`$MailEnabled='$MailEnabled'"
"`$MailNickName='$MailNickName'"
"`$IsForManagementGroupRoleAssignment='$IsForManagementGroupRoleAssignment'"

$result = Get-AzureADGroup -Filter "DisplayName eq '$sgName'"

if ($result.Count -gt 1)
{
	Write-Error "There are '$($result.Count)' security groups with the displayName='$sgName'"
	Exit 1
}
elseif ($result.Count -eq 1)
{
	Write-Warning "$sgName ALREADY EXISTS"
	$result | ConvertTo-JSON
}
else
{
	$CreationResult = New-AzureADGroup -DisplayName $sgName -Description $Description -SecurityEnabled $SecurityEnabled -MailEnabled $MailEnabled -MailNickName $MailNickName
	$CreationResult | Select-Object ObjectId,DisplayName | ConvertTo-JSON | Add-Content -Path .\JSON_OUTPUT.txt

	#$existingOwner=Get-AzureADGroupOwner -ObjectId $result.ObjectId | Where-Object {$_.UserPrincipalName -eq "$CurrentSessionUserPrincipalName"}
	#if (!$existingOwner)
	#{
	#	Add-AzureADGroupOwner -ObjectId $result.ObjectId -RefObjectId $CurrentSessionUserObjectId
	#}
}
