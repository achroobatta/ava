[CmdletBinding()]
param (
    [string]$AdoOrgAgentRegistrationPAT
)

$agentFolderPath    = 'C:\agent'

set-location "$agentFolderPath"

.\config.cmd remove --unattended --auth pat --token $AdoOrgAgentRegistrationPAT