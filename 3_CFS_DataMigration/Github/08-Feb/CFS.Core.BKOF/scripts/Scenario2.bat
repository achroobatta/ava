﻿echo started
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\Users\ADM-AD-DMT-CFS\scripts\Master.ps1 -commRG 'rg-np-edc-bkof-dm-001' -keyVaultNameforSecret 'kv-np-edc-bkof-dm-0028' -secretName 'file2password' -destStorageAccount 'dlgen2npedcbkof6585' -destContainerName 'containerfile2' -deployEnvironment 'Non-Production' -targetDataType 'internal' -sourceDatatype 'sftp' -sourceLocation 'containerforfile2' -vmRG 'sampleRG' -sftpLocalUser 'sampleuser1' -taskNumber 383 -resourceLocation 'australiaeast' -vmName 'sampleVM' -diagStorageAccount 'sampleSTG' -emailAddress 'sampleemail@email.com' -buildId 567890"
    pause
exit /b