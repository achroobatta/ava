param
(
    [Parameter(Mandatory=$false)]
    [String]$unzipPath,
    [Parameter(Mandatory=$false)]
    [String]$localTargetDirectory
)
function Main()
{
    param($unzipPath, $folder)
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Executing Main TVT function") >> $logFilePath

    $reportPath = (Get-ChildItem -Path $unzipPath\$folder | Where-Object {$_.Name -like "*DMF*Report*"}).FullName
    if($null -eq $reportPath)
    {
        return "No Report folder found in $unzipPath\$folder"
    }

    #Treesize
    $treeSizeXlsx = (Get-ChildItem $reportPath -Filter *.xlsx | Where-Object {$_.BaseName -like "*Treesize*"} | Measure-Object).Count
    $treeSizeCsv = (Get-ChildItem $reportPath -Filter *.csv | Where-Object {$_.BaseName -like "*Treesize*"} | Measure-Object).Count
    if($treeSizeXlsx -ne 0 -or $treeSizeCsv -ne 0)
    {
        $treeSize = Get_TreeSize -reportPath $reportPath -unzipPath $unzipPath -folder $folder
        foreach($value in $treeSize) #need to be check if return is only genPath
        {
            if($value -match ".xlsx")
            {
                $treeSizePath = $value
            }
        }
    }
    #MD5
    $md5Xlsx = (Get-ChildItem $reportPath -Filter *.xlsx | Where-Object {$_.BaseName -like "*Hash*"} | Measure-Object).Count
    $md5Csv = (Get-ChildItem $reportPath -Filter *.csv | Where-Object {$_.BaseName -like "*Hash*"} | Measure-Object).Count
    if($md5Xlsx -ne 0 -or $md5Csv -ne 0)
    {
        $md5 = Get_MD5 -unzipPath $unzipPath -folder $folder #need to be check if return is only genPath
        foreach($value in $md5)
        {
            if($value -match ".xlsx")
            {
                $md5Path = $value
            }
        }
    }

    $comresult = Get_Comparison -reportPath $reportPath -treeSize $treeSizePath -md5 $md5Path -unzipPath $unzipPath -folder $folder
    return $comresult
}

function Get_TreeSize()
{
    param($reportPath, $unzipPath, $folder)

    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Generating TreeSize Report") >> $logFilePath

    #Convert csv file to xlsx if not existing
    $csv = Get-ChildItem $reportPath -Filter *.csv | Where-Object {$_.BaseName -like "*Hash*" -or $_.BaseName -like "*Treesize*"}
    if($null -ne $csv)
    {
        foreach($cvrt in $csv)
        {
            $path = $cvrt.FullName
            $name = $cvrt.BaseName
            if (Test-Path -Path "$reportPath\$name.xlsx")
            {
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"$reportPath\$name.xlsx already exist") >> $logFilePath
            }
            else
            {
                Import-Csv -Path $path | Export-Excel "$reportPath\$name.xlsx"
                Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"$name.xlsx is created") >> $logFilePath
            }
        }
    }

    #Path to be Scanned by Treesize application
    $Scanpath = (Get-ChildItem -Path $unzipPath\$folder -Exclude "*report*").FullName
    if($null -eq $Scanpath)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"No data to be scan") >> $logFilePath
        return "No data to be scan"
    }

    $ProgFilePath=[Environment]::GetEnvironmentVariable("ProgramW6432") + "\JAM Software\TreeSize\"
    $reportName = "Treesize-Report-" + $(Get-Date -Format "ddMMyyyyHHmmss") + ".xlsx"
    $genPath = "$unzipPath\$folder\$reportName"

    try
    {
        Start-Process -FilePath "$ProgFilePath\TreeSize.exe" -ArgumentList "/NOGUI /UILevel Simple /SCAN $Scanpath /EXPORTFILES /EXCEL $genPath" -wait
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Generated TreeSize Report") >> $logFilePath
    }
    catch
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Error encountered while executing treesize(exe)") >> $logFilePath
    }

    if(Test-Path -Path $genPath)
    {
        return $genPath
    }
    else
    {
        return $null
    }
}

function Get_Comparison()
{
    param($reportPath, $treeSize, $md5, $unzipPath, $folder)

    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Comparing DMF Report to Generated Report") >> $logFilePath

    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Comparing TreeSize Report") >> $logFilePath
    $arrayResult = @()
    if($null -ne $treeSize)
    {
        $srcTreesize = (Get-ChildItem $reportPath -Filter *.xlsx | Where-Object {$_.BaseName -like "*Treesize*"}).FullName

        $sourcesizes = Import-Excel -Path $srcTreesize -StartRow 5 | Select-Object "Size", "Full Path"
        $sourcefiles = Import-Excel -Path $srcTreesize -StartRow 5 | Select-Object "Files", "Full Path"
        $sourcefolders = Import-Excel -Path $srcTreesize -StartRow 5 | Select-Object "Folders", "Full Path"

        $reportsizes = Import-Excel -Path $treeSize -StartRow 5 | Select-Object "Size", "Full Path"
        $reportfiles = Import-Excel -Path $treeSize -StartRow 5 | Select-Object "Files", "Full Path"
        $reportfolders = Import-Excel -Path $treeSize -StartRow 5 | Select-Object "Folders", "Full Path"

        #Size Comparison
        $sizeresult = @()
        For ($i = 0; $i -lt $sourcesizes.Count ; $i++)
        {
            If ($sourcesizes[$i].Size -ne $reportsizes[$i].Size)
            {
                $sizeresult += "Mismatch Findings: Source Size: " + $sourcesizes[$i].'Full Path' + " Generated Size: " + $reportsizes[$i].'Full Path'
            }
            Else
            {
                continue
            }
        }

        #File Comparison
        $fileresult = @()
        For ($i = 0; $i -lt $sourcefiles.Count ; $i++)
                                            {
            If ($sourcefiles[$i].Files -ne $reportfiles[$i].Files)
            {
                $fileresult += "Mismatch Findings: Source File: " + $sourcesizes[$i].'Full Path' + " Generated File: " + $reportsizes[$i].'Full Path'
            }
            Else
            {
                continue
            }
        }

        #Folders Comparison
        $folderresult = @()
        For ($i = 0; $i -lt $sourcefolders.Count ; $i++)
                                            {
            If ($sourcefolders[$i].Files -ne $reportfolders[$i].Files)
            {
                $folderresult += "Mismatch Findings: Source Folder: " + $sourcesizes[$i].'Full Path' + " Generated Folder: " + $reportsizes[$i].'Full Path'
            }
            Else
            {
                continue
            }
        }

        foreach($missize in $sizeresult)
        {
            $arrayResult += $missize
        }
        foreach($misfile in $fileresult)
        {
            $arrayResult += $misfile
        }
        foreach($misfolder in $folderresult)
        {
            $arrayResult += $misfolder
        }
        if(!($arrayResult))
        {
            $arrayResult += "No mismatch found for Treesize Report of $unzipPath\$folder"
        }
    }
    else
    {
        $arrayResult += "No Generated TreeSize Report for $unzipPath\$folder"
    }
    if($null -ne $md5)
    {

        #MD5 Comparison -------------------------------------------------------------------------------------------------------
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Comparing MD5 Hash Report") >> $logFilePath

        $sHash = (Get-ChildItem $reportPath -Filter *.xlsx | Where-Object {$_.BaseName -like "*Hash*"}).FullName
        $sourceHash = Import-Excel -Path $sHash

        #$genrprtPath = $rootPath + "MD5-Report.xlsx"
        $reportHash = Import-Excel -Path $md5

        $Count =($sourceHash | Measure-Object).Count
        $Results = For ($i = 0; $i -lt $Count; $i++) {
                [PSCustomObject]@{
                MD5 = $sourceHash[$i].MD5
                SHA1 = $sourceHash[$i].SHA1
                FileNames = [System.IO.Path]::GetFileName($sourceHash[$i].FileNames)
            }
        }

        #Compare FilesName and MD5 using compare-object
        $CompareResult = Compare-Object -ReferenceObject $reportHash -DifferenceObject $Results -Property Filenames,MD5 |
            Where-Object { $_.SideIndicator -eq "=>" -or $_.SideIndicator -eq "==" } |
            Sort-Object -Property Filenames |
            Select-Object -Property Filenames,MD5,@{Name="Result";Expression={$_.SideIndicator -replace '==','Match' -replace '=>','Not Match'}}

        #$md5result = $CompareResult.Result
        foreach($mismd5 in $CompareResult)
        {
            $arrayResult += "Mismatch Findings: " + $mismd5.Result + " Result for " + $mismd5.FileNames + " in MD5 Hash Report of $md5 against " + $sHash
        }
        $compareResultCount = ($mismd5 | Measure-Object).Count
        if($compareResultCount -eq 0)
        {
            $arrayResult += "No mismatch found for MD5 Hash Report of $unzipPath\$folder"
        }
    }
    else
    {
        $arrayResult += $arrayResult + "No Generated MD5 Hash Report for $unzipPath\$folder"
    }

    #Copy report to Unzipfile-------------------------------------------------------------------------------
    $xlsSources = (Get-ChildItem -Path $unzipPath\$folder -Filter *.xlsx).FullName
    foreach($xlsSource in $xlsSources)
    {
        Copy-Item -Path $xlsSource -Destination $reportPath
    }

    Remove-Item -Path "$unzipPath\$folder\*.xlsx"

    return $arrayResult
}

function Get_MD5()
{
    param($unzipPath, $folder)

    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Generating MD5 Hash Report") >> $logFilePath

    #Get Hash MD5
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Getting Hash MD5") >> $logFilePath

    $getFolder = (Get-ChildItem -Path $unzipPath\$folder -Exclude "*report*" -Directory).FullName
    $getFiles = (Get-ChildItem -Path $getFolder -Exclude "*report*" -File -Recurse).FullName

    $arrayHash = @()
    foreach($getFile in $getFiles)
    {
        Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Generating Hash MD5 for $getFile") >> "$PSScriptRoot\HashReportProgress.txt"
        $h = certutil -hashfile $getfile MD5
        $hash = $h[1] -replace ' ',''
        $arrayHash += $hash
    }

    #Get File Name and extension
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Getting File Name and extension") >> $logFilePath

    $getNames = Get-ChildItem -Path $getFolder -File -Recurse
    $arrayName = @()
    foreach ($names in $getNames)
    {
        $fileName = $names.Basename
        $fileExtn = $names.Extension
        $fullName = $fileName + $fileExtn
        $arrayName = $arrayName += $fullName
    }

    #Combine Two Object Arrays
    $result = for ($i = 0; $i  -lt $arrayHash.Count; $i++)
    {
        [PSCustomObject]@{
            MD5 = $arrayHash[$i]
            FileNames = $arrayName[$i]
        }
    }

    #Export array to excel file
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Exporting array to excel file") >> $logFilePath

    $hashName = "MD5-Report-" + $(Get-Date -Format "ddMMyyyyHHmmss") + ".xlsx"
    $hashPath = $unzipPath,$folder,$hashName -join "\"
    $result | Export-Excel -Path $hashPath -FreezeTopRow -AutoSize

    if(Test-Path -Path $hashPath)
    {
        return $hashPath
    }
    else
    {
        return $null
    }
}

#----------------------------START-------------------------------

$logFilePath = "$PSScriptRoot\logging_reconcilliationReport.txt"
Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"Start") >> $logFilePath

$reconResult = @()
$orgPath = Get-ChildItem -Path $localTargetDirectory
$folders = $orgPath.BaseName.Replace(" ","_")

foreach ($folder in $folders)
{
    $mResult =  Main -unzipPath $unzipPath -folder $folder
    $reconResult += $mResult
}

foreach($str in $reconResult)
{
    Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),$str) >> $logFilePath
}
Write-Output ("{0} - {1}" -f $((Get-Date).ToString()),"End") >> $logFilePath
return $reconResult