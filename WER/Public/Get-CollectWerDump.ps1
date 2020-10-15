function Get-CollectWerDump
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
        $keyName = "SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\"
        $Names = ($objReg.EnumKey($HKLM, $keyName)).sNames

        if ($Process)
        {
            $Names = $Names | Where-Object {$_ -match $Process}
        }

        foreach ($name in $Names)
        {
            $path = $keyName + $name
            $DumpFolderValue = $objReg.GetStringValue($HKLM, $path, 'DumpFolder')
            $DumpType = $objReg.GetDWORDValue($HKLM, $path, 'DumpType')
            $DumpCount = $objReg.GetDWORDValue($HKLM, $path, 'DumpCount')

            $obj = [PSCustomObject]@{
                ProcessName = $name
                DumpFolder  = $DumpFolderValue.sValue
                DumpCount   = $DumpCount.uValue
                DumpType    = $DumpType.uValue
            }

            if ($ComputerName.Count -gt 1)
            {
                $obj | Add-Member -MemberType NoteProperty -Name 'ComputerName' -Value $Comp
            }

            if ($null -ne $obj)
            {
                $obj
            }
        }
    }
}
