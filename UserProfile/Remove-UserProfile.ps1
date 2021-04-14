function Remove-UserProfile
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Sid')]
        [String]
        $Sid,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = 'Username')]
        [String]
        $UserName,

        [Parameter(ParameterSetName = 'Days')]
        [Int]
        $OlderDays,

        $ComputerName = $env:COMPUTERNAME,

        [PSCredential]
        $Credential,

        [switch]
        $NoLoging
    )

    $LogPath = [System.IO.Path]::Combine($env:TEMP, "RemoveUserProfile" , (Get-Date -Format yyyyMMdd))
    New-Item $LogPath -ItemType Directory -ErrorAction Ignore | Out-Null
    $TimeStart = Get-Date -Format HHmmss

    if ($Credential)
    {
        $Cred = $Credential
    }

    $Prop = @{
        Credential   = $Cred
        ComputerName = $ComputerName
    }

    if ($Sid)
    {
        $Prop.Filter = [string]::Concat("SID LIKE '%", $Sid, "%'")
    }
    if ($UserName)
    {
        $Prop.Filter = [string]::Concat("LocalPath LIKE '%", $UserrjhjName, "%'")
    }
    if ($OlderDays)
    {
        $Time = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime([datetime]::Now.AddDays(-$OlderDays))
        $Prop.Filter = [string]::Concat("LastUseTime < '", $Time, "'")
    }

    try
    {
        $User = Get-WmiObject -Class Win32_UserProfile @Prop -ErrorAction Stop | Sort-Object LastUseTime
        if ($User)
        {
            for ($i = 0; $i -lt $User.Count; $i++)
            {
                $obj = [PSCustomObject]@{
                    LocalPath   = ($User[$i]).LocalPath
                    SID         = ($User[$i]).SID
                    LastUseTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($User[$i].LastUseTime)
                    Action      = "Removed"
                }

                if (-not $NoLoging)
                {
                    $obj | Export-Csv -Path "$LogPath\$ComputerName`_$TimeStart.csv" -Delimiter ';' -NoTypeInformation -Append
                }

                # calculate progress percentage
                $percentage = ($i + 1) / $User.Count * 100
                Write-Progress -Activity "Deleting Users Profile on $ComputerName" -Status "Deleting Profile $($obj.LocalPath) Last Login $($obj.LastUseTime)" -PercentComplete $percentage

                Write-Verbose $obj
                $User[$i] | ForEach-Object {$_.Delete() }
            }
        }
    }
    catch
    {
        Write-Host "$ComputerName $_"
    }

}
