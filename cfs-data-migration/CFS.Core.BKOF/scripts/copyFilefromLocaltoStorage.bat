echo started
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\Users\ADM-AD-DMT-CFS\scripts\copyFilefromLocaltoStorage.ps1 -commRG 'rg-np-edc-bkof-dm-001' -destStorageAccount 'dlgen2npedcbkof6585' -destContainerName 'container6585' -unzipPath 'T:\UnzipFile' -reportPath 'T:\DMF Report'"
    pause
exit /b