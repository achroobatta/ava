param (
    [string]$Fname,
    [string]$Mname,
    [string]$Lname
)
Write-Output "Hello $Fname $Mname $Lname" > "C:\Users\$env:USERNAME\abc.txt"