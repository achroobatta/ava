$acl = Get-Acl 'HKLM:\SOFTWARE'
$acl.Access
$idRef = [System.Security.Principal.NTAccount]("demovm\demousr")
$regRights = [System.Security.AccessControl.RegistryRights]::FullControl
$inhFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
$prFlags = [System.Security.AccessControl.PropagationFlags]::None
$acType = [System.Security.AccessControl.AccessControlType]::Allow
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($idRef, $regRights, $inhFlags, $prFlags, $acType)
$acl.AddAccessRule($rule)
$acl | Set-Acl -Path 'HKLM:\SOFTWARE'
(Get-Acl 'HKCU:\Software').Access