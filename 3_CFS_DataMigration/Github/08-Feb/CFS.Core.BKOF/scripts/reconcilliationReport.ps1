param
(
    [Parameter(Mandatory=$true)]
    [String]$unzipPath,
    [Parameter(Mandatory=$true)]
    [String]$localTargetDirectory
)
function Main()
{
    param($unzipPath, $folder)

    $reportPath = (Get-ChildItem -Path $unzipPath\$folder | Where-Object {$_.Name -like "*Report*"}).FullName
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

    Write-Information "Generating TreeSize Report" #outfile

    $csv = Get-ChildItem $reportPath -Filter *.csv | Where-Object {$_.BaseName -like "*Hash*" -or $_.BaseName -like "*Treesize*"}
    if($null -ne $csv)
    {
        foreach($cvrt in $csv)
        {
            $path = $cvrt.FullName
            $name = $cvrt.BaseName
            if (Test-Path -Path "$reportPath\$name.xlsx")
            {
                #Write-Information "$reportPath\$name.xlsx already exist" #outfile

            }
            else
            {
                Import-Csv -Path $path | Export-Excel "$reportPath\$name.xlsx"
            }
        }
    }
    #Path to be Scanned by Treesize application
    $Scanpath = (Get-ChildItem -Path $unzipPath\$folder -Exclude "*report*").FullName
    if($null -eq $Scanpath)
    {
        #outfile
        return "No data to be scan"
    }

    $ProgFilePath=[Environment]::GetEnvironmentVariable("ProgramW6432") + "\JAM Software\TreeSize\"
    $reportName = "Treesize-Report-" + $(Get-Date -Format "ddMMyyyyHHmmss") + ".xlsx"
    $genPath = $unzipPath,$folder,$reportName -join "\"

    Start-Process -FilePath "$ProgFilePath\TreeSize.exe" -ArgumentList "/NOGUI /UILevel Simple /SCAN $Scanpath /EXPORTFILES /EXCEL $genPath" -wait

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

    Write-Information "Comparing DMF Report to Generated Report"

    $arrayResult = @()
    if($null -ne $treeSize)
    {
        $srcTreesize = (Get-ChildItem $reportPath | Where-Object {$_.BaseName -like "*Treesize*"}).FullName

        $sourcesizes = Import-Excel -Path $srcTreesize -StartRow 5 | Select-Object "Size", "Full Path"
        $sourcefiles = Import-Excel -Path $srcTreesize -StartRow 5 | Select-Object "Files", "Full Path"
        $sourcefolders = Import-Excel -Path $srcTreesize -StartRow 5 | Select-Object "Folders", "Full Path"

        $reportsizes = Import-Excel -Path $treeSize -StartRow 5 | Select-Object "Size", "Full Path"
        $reportfiles = Import-Excel -Path $treeSize -StartRow 5 | Select-Object "Files", "Full Path"
        $reportfolders = Import-Excel -Path $treeSize -StartRow 5 | Select-Object "Folders", "Full Path"

        #Size Comparison
        $sizeresult = @()
        For ($i = 0; $i -lt $Count; $i++)
        {
            If ($sourcesizes[$i].Size -ne $reportsizes[$i].Size)
            {
                $sizeresult += "Mismatch: Source Size: " + $sourcesizes[$i].'Full Path' + "Generated Size" + $reportsizes[$i].'Full Path'

            }
            Else
            {
                continue
            }
        }

        #File Comparison
        $fileresult = @()
        For ($i = 0; $i -lt $Count; $i++)
                                            {
            If ($sourcefiles[$i].Files -ne $reportfiles[$i].Files)
            {
                $sizeresult += "Mismatch: Source File: " + $sourcesizes[$i].'Full Path' + "Generated File" + $reportsizes[$i].'Full Path'
            }
            Else
            {
                continue
            }
        }

        #Folders Comparison
        $folderresult = @()
        For ($i = 0; $i -lt $Count; $i++)
                                            {
            If ($sourcefolders[$i].Files -ne $reportfolders[$i].Files)
            {
                $sizeresult += "Mismatch: Source Folder: " + $sourcesizes[$i].'Full Path' + "Generated Folder" + $reportsizes[$i].'Full Path'
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
        if($null -eq $arrayResult)
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
        $sHash = (Get-ChildItem $reportPath | Where-Object {$_.BaseName -like "*Hash*"}).FullName
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

        $CompareResult = Compare-Object -ReferenceObject $Results -DifferenceObject $reportHash -Property Filenames,MD5 |
            Where-Object { $_.SideIndicator -eq "=>" -or $_.SideIndicator -eq "==" } |
            Sort-Object -Property Filenames |
            Select-Object -Property Filenames,MD5,@{Name="Result";Expression={$_.SideIndicator -replace '==','Match' -replace '=>','Not Match'}}

        #$md5result = $CompareResult.Result
        foreach($mismd5 in $CompareResult)
        {
            $arrayResult += $mismd5.Result + " Result for " + $mismd5.FileNames + " in MD5 Hash Report of $md5 against " + $sHash
        }
        $compareResultCount = ($md5result | Measure-Object).Count
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

    Write-Information "Generating MD5 Hash Report" #outfile

    #Get Hash MD5
    $getFolder = (Get-ChildItem -Path $unzipPath\$folder -Exclude "*report*" -Directory).FullName
    $getFiles = (Get-ChildItem -Path $getFolder -Exclude "*report*" -File -Recurse).FullName

    $arrayHash = @()
    foreach($getFile in $getFiles)
    {
        $h = certutil -hashfile $getfile MD5
        $hash = $h[1] -replace ' ',''
        $arrayHash += $hash
    }
    #Get File Name and extension
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
$reconResult = @()
$folders = Get-ChildItem -Path $localTargetDirectory
foreach ($folder in $folders)
{
    $mResult =  Main -unzipPath $unzipPath -folder $folder
    $reconResult += $mResult
}
return $reconResult