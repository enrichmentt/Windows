function Get-Wer
{
    <#
    .SYNOPSIS
    Получение значения WER

    .DESCRIPTION
    Получение значения Windows Error Repotring

    .PARAMETER ComputerName
    Имя удаленного компьютера

    .PARAMETER Credential
    Учетная запись для доступа

    .EXAMPLE
    Get-Wer
    Получение значения WER на локальном компьютере

    .EXAMPLE
    Get-Wer -ComputerName %computername%
    Получение значения WER на удаленном компьютере

    .EXAMPLE
    Get-Wer -ComputerName %computer% -Credential %username%
    Получение значения WER на удаленном компьютере с указанием учетной записи

    .NOTES
    Значение 1 у ключа Disabled в SOFTWARE\Microsoft\Windows\Windows Error Reporting

    #>

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

        $res = $objReg.GetDWORDValue($hklm, $keyName, 'Disabled')

        $obj = [PSCustomObject]@{
            ComputerName = $Comp
        }

        if ($res.uValue -eq 1)
        {
            $obj | Add-Member -MemberType NoteProperty -Name 'Result' -Value "Disabled"
        }
        elseif ($res.uValue -eq 0)
        {
            $obj | Add-Member -MemberType NoteProperty -Name 'Result' -Value "Enabled"
        }
        else
        {
            $obj | Add-Member -MemberType NoteProperty -Name 'Result' -Value "Unknown"
        }

        Write-Output $obj
    }
}
