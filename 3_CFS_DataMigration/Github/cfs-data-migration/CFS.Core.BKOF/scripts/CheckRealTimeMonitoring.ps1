<#
.SYNOPSIS
 Enable Real Time Monitoring
.DESCRIPTION
  This script will be used to enable real time monitoring for Microsoft Defender.


.NOTES
  Version:        1.0
  Author:         Abaigail Rose Artagame
  Creation Date:  2/3/2023
  Purpose/Change: Initial script development

#>


#-----------------------------------------------------------[Declarations]------------------------------------------------------------
#Parameters

# No Parameters needed
#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Logging {
  <#
        .SYNOPSIS
        Logging purposes

        .DESCRIPTION
        Create a backend logging for SecurityScan.ps1

        .PARAMETER LogPath
        Log Path

        .PARAMETER Message
        Message to be log
    #>
  Param(

    $LogPath,
    $Message
  )
  Begin {
  }
  Process {
    Try {

      Write-Output '***********************************************' >> $LogPath
      Write-Output ("{0} - {1}" -f $((Get-Date).ToString()), $Message) >> $LogPath

    }
    Catch {
      throw "Error in logging $Message to $LogPath"
    }
  }
  End {}
}
Function CheckRealTimeMonitoring {
  $RTMResult = @()
  try {
    #Creating Log Folder
    $logDirectory = "$PSScriptRoot/CheckRealTimeMonitoring"
    #region Log Folder
    #Checking if Log Folder is existing
    if (Test-Path -LiteralPath $logDirectory) {
      #Do Nothing
    }
    else {
      New-Item -Itemtype "Directory" -Path $logDirectory
    }
    #Creating Log File
    $logPath = "$PSScriptRoot/CheckRealTimeMonitoring/SecurityScan-Log-" + $(Get-Date -Format "ddMMyyyyHHmmss") + ".txt"
    #endregion
    #region Update Microsoft Defender
    try {
      #Updating Microsoft Defender to have the latest definition
      Logging -LogPath $logPath -Message "Updating for Microsoft Defender..."

      for ($i = 1; $i -le 2; $i++) {
        try {
          $updateMpSignature = Update-MpSignature
          if ($null -eq $updateMpSignature) {
            Logging -LogPath $logPath -Message "Updated Microsoft Defender with the latest definition"
            break
          }
        }
        catch {
          Logging -LogPath $logPath -Message "Failed to update running retry..."
          Start-Sleep -Seconds 60
        }
      }
    }
    catch {
      $RTMResult += "RTM Error: Failed to ran Update-MpSignature"
    }
    #endregion
    #region Get Microsoft Defender Status: Antivirus and AntiSpyware
    try {
      for ($i = 1; $i -le 2; $i++) {
        try {
          $getMpStatus = Get-MpComputerStatus
          if ($getMpStatus.AntivirusEnabled -eq $true -or $getMpStatus.AntivirusEnabled -eq $false ) {
            Logging -LogPath $logPath -Message "Successfully Get MP Status"
            $getMpStatusSuccess = $true
            break
          }
        }
        catch {
          Logging -LogPath $logPath -Message "Failed to get mp status running retry..."
          Start-Sleep -Seconds 60
        }
      }
      if ($getMpStatusSuccess -eq $true) {
        #region Antivirus
        Logging -LogPath $logPath -Message "Checking if  Antivirus is enabled ..."
        if ($getMpStatus.AntivirusEnabled -eq $true) {
          Logging -LogPath $logPath -Message "Successfully checked Antivirus status: Antivirus is enabled."
        }
        else {
          $RTMResult += "RTM Error: AntiVirus is not enabled"
        }
        #endregion
        #region AntiSpyware
        Logging -LogPath $logPath -Message "Checking if  AntiSpyware is enabled ..."
        if ($getMpStatus.AntispywareEnabled -eq $true) {
          Logging -LogPath $logPath -Message "Successfully checked AntiSpyware status: AntiSpyware is enabled."
        }
        else {
          $RTMResult += "RTM Error: AntiSpyware is not enabled"
        }
        #endregion
        #region Checking if Real Time Monitoring is enabled
        Logging -LogPath $logPath -Message "Checking if Real Time Protection is enabled..."
        if ($getMpStatus.RealTimeProtectionEnabled -eq $true) {
          Logging -LogPath $logPath -Message "Real Time Protection is already enabled"

        }
        else {
          Logging -LogPath $logPath -Message "Real Time Protection is not enabled..."
          $RTMResult += "RTM Error: Real Time Protection is not enabled"
        }
        #endregion
      }
      #endregion
    }
    catch {
      Logging -LogPath $logPath -Message "An issue occured in checking Microsoft Defender status with error: $_.ErrorDetails.Message"
      $RTMResult += "RTM Error: Failed to ran command Get-MpComputerStatus"

    }
  }
  catch {
    Logging -LogPath $logPath -Message "Failed with error: $_.ErrorDetails.Message"
    $RTMResult = "RTM Error: Failed to execute the script"
  }
  return $RTMResult
}
#-----------------------------------------------------------[Execution]------------------------------------------------------------
$RTMResult = CheckRealTimeMonitoring

$resultRTM = @()
if ($null -ne $RTMResult) {
  if ($RTMResult.GetType().Name -eq "DirectoryInfo") {
    return "Real Time Monitoring Enabled"

  }
  else {
    foreach ($result in $RTMResult) {
      if ($result -like "*RTM Error:*") {
        $resultRTM += $result
      }
    }
    return $resultRTM
  }
}
else {
  return "Real Time Monitoring Enabled"
}
