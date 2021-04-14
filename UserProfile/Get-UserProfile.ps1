function Get-UserProfile
{
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [String[]]
        $ComputerName = $env:COMPUTERNAME,

        [PSCredential]
        $Credential,

        [int]
        $OlderDays
    )

    if ($Credential)
    {
        $Cred = $Credential
    }

    $Prop = @{
        Credential = $Cred
        Filter     = "Special=False"
    }

    if ($OlderDays)
    {
        $Time = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime([datetime]::Now.AddDays(-$OlderDays))
        $Prop.Filter += [string]::Concat(" AND ", "LastUseTime < '", $Time, "'")
    }

    $Object = @()

    foreach ($Comp in $ComputerName)
    {
        try
        {
            $Users = Get-WmiObject Win32_UserProfile  -ComputerName $Comp @Prop -ErrorAction Stop
        }
        catch
        {
            Write-Host $_
        }


        foreach ($User in $Users)
        {
            try
            {
                $Object += [PSCustomObject]@{
                    LocalPath    = $User.LocalPath
                    UserName     = $User.LocalPath.Split('\')[$User.LocalPath.Split('\').Length - 1]
                    LastUseTime  = [System.Management.ManagementDateTimeConverter]::ToDateTime($User.LastUseTime)
                    Loaded       = $User.Loaded
                    SID          = $User.SID
                    ComputerName = $Comp
                }
            }
            catch {Write-Host $_}
        }

        if ($ComputerName.Length -ge 2)
        {
            $Object += ""
        }
    }

    $Object
}
