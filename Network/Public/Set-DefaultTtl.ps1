#requires –RunAsAdministrator

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    $TTL
)

try
{
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ -Name DefaultTTL -Value $TTL

    $ans = Read-Host "Restart computer?[y/n]"
    if ($ans.ToUpper() -eq "Y")
    {
        Restart-Computer
    }
}
catch
{
    Write-Host $_
}
