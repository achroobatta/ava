<#
.SYNOPSIS
  Read Excel file and save values from it into a variable group.
.DESCRIPTION
  This script will be used to read the downloaded excel file from the artifacts and update the variables values in the variable group.

.NOTES
  Version:        1.0
  Author:         Abaigail Rose Artagame
  Creation Date:  29/11/2022
  Purpose/Change: Initial script development


#>


#-----------------------------------------------------------[Declarations]------------------------------------------------------------
param(
  $ExcelFilePath,
  $SheetName
)


#-----------------------------------------------------------[Functions]------------------------------------------------------------
# Function Set_VariableValue{
#   <#
#         .SYNOPSIS
#         Save Work Item Id as variable in a Variable Group

#         .DESCRIPTION
#         Save Work Item Id as variable in a Variable Group

#         .PARAMETER VariableGroupId
#         Variable Group Id

#         .PARAMETER VariableName
#         Variable Name to be updated

#         .PARAMETER VariableValue
#         Variable value
#     #>
#   Param(

#     $VariableGroupId,
#     $VariableName,
#     $VariableValue

#   )
#   Begin{
#     Write-Information -MessageData "Updating Variable $VariableName..." -InformationAction Continue
#   }
#   Process
#   {
#     Try{
#       az devops login
#       az pipelines variable-group variable update --group-id $VariableGroupId --name $VariableName --value $VariableValue --org $($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI) --project $env:SYSTEM_TEAMPROJECTID

#       return $true
#     }
#     Catch
#     {
#       return $false
#     }
#   }
#   End{}
# }
#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Read Excel File
$VariableNameColumn = 4
$ValueColumn = 5
$StartRow = 1
Install-Module -Name ImportExcel -Force
[array]$Data = Import-Excel -Path $ExcelFilePath -ImportColumns @($VariableNameColumn,$ValueColumn) -StartRow $StartRow -WorksheetName $SheetName


#Loop into Rows
foreach($Row in $Data)
{
    if(![string]::IsNullOrEmpty($Row.'VariableName in Pipeline'))
    {
      $VariableName = $Row.'VariableName in Pipeline'
      $VariableValue = $Row.Values
      #Save as Stage Output Variable
      Write-Output "##vso[task.setvariable variable=$VariableName;isOutput=true]$VariableValue"

    }
}
