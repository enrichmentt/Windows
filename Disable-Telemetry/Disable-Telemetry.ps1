
function Disable-Telemetry
{
    [CmdletBinding()]
    param (
        [string[]] $ComputerName = $env:COMPUTERNAME,
        [PScredential]$Credential
    )

    $HKLM = "2147483650"
    $KeyName = "SOFTWARE\Policies\Microsoft\Windows\"
    $SubKeyName = [System.IO.Path]::Combine($keyName, "DataCollection")
    $ValueName = "AllowTelemetry"
    $Value = 0

    if ($Credential)
    {
        $cred = $Credential
    }

    foreach ($Comp in $ComputerName)
    {
        try
        {
            $objReg = Get-WmiObject -List -Namespace 'root\default' -ComputerName $Comp -Credential $cred | Where-Object { $_.Name -eq "StdRegProv" } -ErrorAction Stop
    
            $returnSetValue = $objReg.SetDWORDValue($HKLM, $SubKeyName, $ValueName, $Value)

            Write-Host "$Comp return value is $($returnSetValue.returnValue)"
        }
        catch
        {
            Write-Host $_ -ForegroundColor Red
        }
    }
}