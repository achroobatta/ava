param(
    [Parameter(Mandatory=$true)]
    [string]
    $pwd,
    [Parameter(Mandatory=$true)]
    [string]
    $depStorageAccount
)

$logFilePath = "$env:USERPROFILE\logging_FileMount.txt"

if (Test-Path -Path $logFilePath) {
    Remove-Item $logFilePath
}
Write-Output '***************************************************' >> $logFilePath
Write-Output 'Start' > $logFilePath
Write-Output '***************************************************' >> $logFilePath
Write-Output "Parameters Value" >> $logFilePath
Write-Output '***************************************************' >> $logFilePath
Write-Output $depStorageAccount >> $logFilePath
Write-Output $pwd >> $logFilePath
Write-Output $env:USERPROFILE >> $logFilePath
Write-Output '***************************************************' >> $logFilePath

$depComputerName = "$depStorageAccount.file.core.windows.net"
$depFileShare = "\\$depStorageAccount.file.core.windows.net\installablemodulesforvm"
$user = "localhost\$depStorageAccount"

Write-Output "interpolated Values" >> $logFilePath
Write-Output '***************************************************' >> $logFilePath
Write-Output $depComputerName >> $logFilePath
Write-Output $depFileShare >> $logFilePath
Write-Output $user >> $logFilePath
Write-Output '***************************************************' >> $logFilePath

$connectTestResult = Test-NetConnection -ComputerName $depComputerName -Port 445

if ($connectTestResult.TcpTestSucceeded) {
    Write-Output "Within IF" >> $logFilePath
    Write-Output '***************************************************' >> $logFilePath
    $User = $user
    Write-Output $User >> $logFilePath
    #$Password = ConvertTo-SecureString -String $pwd -AsPlainText -Force
    $string = New-Object System.Net.NetworkCredential("",$pwd)
    $Password = $string.SecurePassword
    Write-Output $Password >> $logFilePath
    $Cred = [pscredential]::new($User,$Password)
    Write-Output $Cred >> $logFilePath
    New-PSDrive -Name Z -PSProvider FileSystem -Root $depFileShare -Scope Global -Persist -Credential $Cred
    $status =net use
    if (!(Test-Path -path "$env:USERPROFILE\softwares\")) {
        New-Item -ItemType "directory" -Path $env:USERPROFILE\softwares -Force
    }
    Write-Output $status >> $logFilePath
    Copy-Item "$depFileShare\*" -Destination "$env:USERPROFILE\softwares\" -Recurse -Force
    Get-ChildItem "$env:USERPROFILE\softwares\" >> $logFilePath
    Write-Output '***************************************************' >> $logFilePath
} else {
    Write-Output "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port." >> $logFilePath
}

Write-Output '***************************************************' >> $logFilePath
Write-Output 'End' >> $logFilePath
Write-Output '***************************************************' >> $logFilePath