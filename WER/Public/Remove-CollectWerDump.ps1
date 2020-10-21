function Remove-CollectWerDump
{
    param (
        [string]
        $Process,

        [string[]]
        $ComputerName = $env:COMPUTERNAME,

        [PScredential]
        $Credential
    )

    if ($Credential)
    {
        $cred = $Credential
    }

    foreach ($Comp in $ComputerName)
    {
        try
        {
            $objReg = Get-WmiObject -ComputerName $Comp -Credential $cred -Namespace "root\default" -List -ErrorAction Stop | Where-Object {$_.Name -eq "StdRegProv"}
        }
        catch
        {
            Write-Host $Comp $_ -NoNewline
            continue
        }

        [string] $HKLM = "2147483650"
        $keyName = "SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps"
        $Names = ($objReg.EnumKey($HKLM, $keyName))

        foreach ($name in $Names.sNames)
        {
            $path = [System.IO.Path]::Combine($keyName, $name)

            if ($Process -eq $name)
            {
                $return = $objReg.DeleteKey($HKLM, $path)
                Write-Host "Deleted $path on $Comp return value is $($return.ReturnValue)"
            }
            elseif (-not $Process)
            {
                $return = $objReg.DeleteKey($HKLM, $path)
            }
        }

        if (-not $Process)
        {
            $return = $objReg.DeleteKey($HKLM, $keyName)
            Write-Host "Deleted $keyName on $Comp return value is $($return.ReturnValue)"
        }
    }
}
