function Get-UserProfile
{
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [String[]]
        $ComputerName = $env:COMPUTERNAME,

        [PSCredential]
        $Credential
    )

    if ($Credential)
    {
        $Cred = $Credential
    }

    $Object = @()

    foreach ($Comp in $ComputerName)
    {
        try
        {
            $Users = Get-WmiObject Win32_UserProfile  -ComputerName $Comp -Credential $cred -Filter "Special=False" -ErrorAction Stop
        }
        catch
        {
            Write-host $_
        }
    
    
        $wmi = [WMI] ""
        foreach ($User in $Users)
        {
            $Object += [PSCustomObject]@{
                LocalPath    = $user.LocalPath
                LastUseTime  = $wmi.ConvertToDateTime($User.LastUseTime)
                Loaded       = $User.Loaded
                SID          = $User.SID
                ComputerName = $Comp
            }
        }

        if ($ComputerName.Length -ge 2)
        {
            $Object += ""
        }
    }

    $Object
}