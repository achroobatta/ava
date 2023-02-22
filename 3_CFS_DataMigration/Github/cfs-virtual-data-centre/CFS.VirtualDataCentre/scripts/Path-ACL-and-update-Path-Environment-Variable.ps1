# add each path you require here, the script will check if the path is already in the environment variable before adding it.
$paths=@(
	"C:\Windows\SysWOW64\config\systemprofile\AppData\Local\Programs\Bicep CLI"
)

$windowsServiceIdentity='NT AUTHORITY\NETWORK SERVICE'


"=== before ==="
[System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine).Split(';')

foreach ($p in $paths) {
	$p = $p.Replace('/', '\')
	$currentPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine).Replace('/', '\')
	if ( ($currentPath.Split(';') -notcontains $p) -And ($currentPath.Split(';') -notcontains $p+"\") ) {
		"does not contain $p"
		# this will save in this registry key : Computer\HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Environment\Path
		# and also mirrored at Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Path
		[System.Environment]::SetEnvironmentVariable('PATH', $currentPath + ";$p", [System.EnvironmentVariableTarget]::Machine)
	} else {
		"contains $p"
	}

	#change ACL
	"updating access to '$p' for '$windowsServiceIdentity'"
	icacls.exe "$p" /grant "$($windowsServiceIdentity):(OI)(CI)(RX)"
}

"=== after ==="
[System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine).Split(';')