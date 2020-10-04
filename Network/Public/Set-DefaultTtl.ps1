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
    Restart-Computer
}
catch
{
    Write-Host $_
}
