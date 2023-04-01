param(
    [Parameter(Mandatory=$True)]
    [string] $hostPoolRg,
    [Parameter(Mandatory=$True)]
    [string] $hostPoolName
)

try
{
   Write-Information -MessageData "Generating Registration Key for $hostPoolName" -InformationAction Continue
   $createRegistrationKey = New-AzWvdRegistrationInfo -ResourceGroupName $hostPoolRg -HostPoolName $hostPoolName -ExpirationTime $((Get-Date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
   $registrationKey = $createRegistrationKey.Token
   Write-Information -MessageData "Generation of Registration Key for $hostPoolName is successful" -InformationAction Continue
   Write-Output "##vso[task.setvariable variable=RegistrationKey]$registrationKey"
}
catch
{
   Write-Error $_
   break
}
