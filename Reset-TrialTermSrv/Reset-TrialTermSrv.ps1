$user = $env:USERNAME

cmd /c "SetACL.exe -on `"hklm\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod`" -ot reg -actn setowner -ownr `"n:$user`""

if (($user -notlike "*SYSTEM*") -or ($user -notlike "*ALL APPLICATION PACKAGE*") -or ($user -notlike "*NETWORK SERVICE*"))
{
    cmd /c "SetACL.exe -on `"hklm\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod`" -ot reg -actn ace -ace `"n:$user;p:full`""

    $acl = Get-Acl 'hklm:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod'
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule ("$user", "FullControl", "Allow")
    $acl.RemoveAccessRuleAll($rule)
    Set-Acl 'hklm:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod' $acl
}

Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod' -Name 'L$RTMTIMEBOMB_1320153D-8DA3-4e8e-B27B-0D888223A588'

cmd /c 'SetACL.exe -on "hklm\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod" -ot reg -actn setowner -ownr "n:NETWORK SERVICE"'