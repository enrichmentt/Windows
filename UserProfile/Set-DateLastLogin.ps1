function Set-DateLastLogin
{
    <#
    .SYNOPSIS
    Изменение даты последнего входа пользователя в систему

    .DESCRIPTION
    После применения обновлений на Windows Server 2012+ выставляется дата профиля на момент применения.
    Этим скриптом мы ставим дату изменения ntuser.dat
    равной дате файла AppData\Local\Microsoft\Windows\UsrClass.dat (он меняется только при входе)

    .PARAMETER ComputerName
    Имя компьютера

    .PARAMETER Credential
    Учетные данные

    .EXAMPLE
    Set-LastLogin -ComputerName n7701-sys001

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param
    (
        [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 -Quiet})]
        [string]$ComputerName,
        [pscredential]$Credential
    )

    $LogPath = [System.IO.Path]::Combine($env:TEMP, "ChangeDateLogon" , (Get-Date -Format yyyyMMdd))
    New-Item $LogPath -ItemType Directory -ErrorAction Ignore | Out-Null
    $TimeStart = Get-Date -Format HHmmss

    $null | Remove-PSDrive -Name "V" -Force -ErrorAction Ignore

    $DiskParam = @{
        Name        = 'V'
        Root        = "\\$ComputerName\C$\Users"
        PSProvider  = "FileSystem"
        ErrorAction = "Stop"
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $DiskParam.Credential = Get-Credential $Credential
    }


    try
    {
        $Drive = New-PSDrive @DiskParam
    }
    catch
    {
        Write-Host $_
    }

    $users = (Get-ChildItem -Path "V:\" | `
            Where-Object { (($_.Name -match "\w{1}\d{4}-\d{5}") -or ($_.Name -match "\w{1}\d{4}-\d{3}-\d{2}") -or ($_.Name -match "\w{1}\d{4}-\d{2}-\d{3}")) }).Name
    foreach ($user in $users)
    {
        $path = "V:\$user\AppData\Local\Microsoft\Windows\UsrClass.dat"
        Write-Verbose "Путь реальной даты входа пользователя $user - $path"

        if ((Test-Path $path))
        {
            $LastDateFileNTUSERpol = Get-ChildItem -Path $path -Force
            $NTUser = Get-ChildItem -Path "V:\$user\ntuser.dat" -Force
            Write-Verbose "Последняя дата входа пользователя $user - $($LastDateFileNTUSERpol.LastWriteTime)"

            [PSCustomObject]@{
                UserName             = $user
                LogonTimeBeforChange = $NTUser.LastWriteTime
                LogonTimeAfterChange = $LastDateFileNTUSERpol.LastWriteTime
            } | Export-Csv -Path "$LogPath\$ComputerName`_$TimeStart.csv" -Delimiter ';' -NoTypeInformation -Append

            if ($null -ne $LastDateFileNTUSERpol.LastWriteTime)
            {
                try
                {
                    ($NTUser).LastWriteTime = $LastDateFileNTUSERpol.LastWriteTime
                }
                catch
                {
                    Write-Host $_
                }
            }
        }

        $LastDateFileNTUSERpol = $null
    }

    Remove-PSDrive -Name "V" -Force -ErrorAction Ignore
}
