param(
    [Parameter(Mandatory=$True)]
    [string] $env,
    [Parameter(Mandatory=$True)]
    [string] $appName
)

try
{
   $keyPath = "C:/temp/certs/$appName" + "_" + "$env"
   if(Test-Path $keyPath)
   {
   }
   else
   {
    New-Item -Itemtype "Directory"-Path $keyPath
   }
   ssh-keygen -t rsa -b 4096 -f $keyPath/$appName -N "passphrase"
}
catch
{
   $logPath = "$env:USERPROFILE/SSHKey-Log-" + $(Get-Date -Format "ddMMyyyyHHmmss") + ".txt"
   $_ | Out-File $logPath
}
