echo started
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\Users\ADM-AD-DMT-CFS\scripts\copyfromStoragetoDisk.ps1 -commRG 'rg-np-edc-bkof-dm-001' -sourceStorageAccount 'sstornpedcbkofdm001' -localTargetDirectory 'S:\FromStorageAccount' -sourceLocation 'containerforfile4'"
    pause
exit /b