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

param(
    [Parameter(Mandatory = $true)]
    [string]$localTargetDirectory
)
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
Function CheckThreatReport {
    param(
        [string] $localTargetDirectory
    )
    try {
        $CheckThreatResult = @()
        #Creating Log Folder
        $logDirectory = "$PSScriptRoot/CheckThreat-Logs"
        #region Log Folder
        #Checking if Log Folder is existing
        if (Test-Path -LiteralPath $logDirectory) {
            #Do Nothing
        }
        else {
            New-Item -Itemtype "Directory" -Path $logDirectory
        }
        #Creating Log File
        $logPath = "$PSScriptRoot/CheckThreat-Logs/SecurityScan-Log-" + $(Get-Date -Format "ddMMyyyyHHmmss") + ".txt"
        #endregion
        #region Get Threat Logs
        try {
            #Updating Microsoft Defender to have the latest definition
            Logging -LogPath $logPath -Message "Checking Threat Logs..."
            $threatLogs = Get-MpThreat
            if ($null -eq $threatLogs) {
                Logging -LogPath $logPath -Message "No Threat Found"
            }
            else {
                $threatLogs = Get-MpThreatDetection| Select-Object -ExpandProperty resources
                foreach ($threat in $threatLogs) {
                    $threat = $threat.Replace("file:_","")
                    $threat = $threat.Replace("containerfile:_","")
                    $threatDirectory = Split-Path $threat -Parent
                    if ($threatDirectory -like "*$localTargetDirectory*") {
                        $CheckThreatResult += "Threat Found: $threat"
                        Logging -LogPath $logPath -Message "Threat Found: $threat"
                    }
                }
            }
        }
        catch {
            Logging -LogPath $logPath -Message "An issue occured in checking threat logs with error: $_.ErrorDetails.Message"
            $CheckThreatResult += "Check Threat Error: $_.ErrorDetails.Message"
        }
        #endregion
    }
    catch {
        $CheckThreatResult = "Check Threat Error: $_.ErrorDetails.Message"
    }
    return $CheckThreatResult
}
#-----------------------------------------------------------[Execution]------------------------------------------------------------
$CheckThreatResult = CheckThreatReport -localTargetDirectory $localTargetDirectory

if ($CheckThreatResult.Length -gt 0) {
    return $CheckThreatResult
}
else {
    return "No Threat Found"
}