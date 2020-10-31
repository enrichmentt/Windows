function Disable-Wer
{
    <#
    .SYNOPSIS
    Выключение WER

    .DESCRIPTION
    Выключение Windows Error Repotring

    .PARAMETER ComputerName
    Имя удаленного компьютера

    .PARAMETER Credential
    Учетная запись для доступа

    .EXAMPLE
    Disable-Wer
    Выключение WER на локальном компьютере

    .EXAMPLE
    Disable-Wer -ComputerName %computername%
    Выключение WER на удаленном компьютере

    .EXAMPLE
    Disable-Wer -ComputerName %computer% -Credential %username%
    Выключение WER на удаленном компьютере с указанием учетной записи

    .NOTES
    Значение 1 у ключа Disabled в SOFTWARE\Microsoft\Windows\Windows Error Reporting

    #>#

    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string[]]
        $ComputerName = $env:COMPUTERNAME,

        [Parameter(Position = 1)]
        [PScredential]
        $Credential
    )

    if ($Credential)
    {
        $cred = $Credential
    }

    [string] $HKLM = "2147483650"
    $keyName = "SOFTWARE\Microsoft\Windows\Windows Error Reporting"

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

        $res = $objReg.SetDWORDValue($hklm, $keyName, 'Disabled', 1)

        $obj = [PSCustomObject]@{
            ComputerName = $Comp
            ReturnValue  = $res.ReturnValue
        }

        if ($res.ReturnValue -eq 0)
        {
            $obj | Add-Member -MemberType NoteProperty -Name 'Result' -Value $true
        }
        else
        {
            $obj | Add-Member -MemberType NoteProperty -Name 'Result' -Value $false
        }

        Write-Output $obj
    }
}
