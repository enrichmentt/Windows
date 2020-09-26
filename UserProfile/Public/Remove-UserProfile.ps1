function Remove-UserProfile
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [String]
        $Sid,

        [Parameter(ValueFromPipeline = $true)]
        [String]
        $UserName,

        [Parameter(ParameterSetName = 'Days')]
        [Int]
        $OlderDays,

        $ComputerName = $env:COMPUTERNAME
    )

    $Prop = @{
        Filter = $null
    }

    if ($Sid)
    {
        $Prop.Filter = "SID LIKE '$Sid'"
    }


    if($UserName)
    {
        $Prop.Filter = "LocalPath LIKE '$UserName'"
    }


    try
    {
        Get-WmiObject Win32_UserProfile @Prop | ForEach-Object {$_.Delete()}
    }
    catch
    {
        
    }

}