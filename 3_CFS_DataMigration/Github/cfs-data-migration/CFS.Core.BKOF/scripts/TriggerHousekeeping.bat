echo started
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\Users\ADM-AD-DMT-CFS\scripts\TriggerHousekeeping.ps1 -taskNumber 383  -deployEnvironment 'Non-Production' -vmName 'sampleVM' -vmRG 'rg-np-edc-bkof-dm-vm-001' -diagStorageAccount 'sampleSTG' -resourceLocation 'australiaeast' -emailAddress 'sampleemail@email.com' -commRG 'rg-np-edc-bkof-dm-001' -sftpLocalUser 'sampleuser1' -targetDataType 'external' -destStorageAccount 'dlgen2npedcbkof6585' -destContainerName 'container6585' -keyVaultNameforSecret 'kv-np-edc-bkof-dm-0028'"
    pause
exit /b