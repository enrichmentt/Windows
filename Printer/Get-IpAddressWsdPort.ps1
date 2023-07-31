
param(
    $ComputerName = "prn-01",
    $PrinterName = "R-PRN68",
    [pscredential]$Credentials
)


$Session = New-CimSession -ComputerName $ComputerName -Credential $Credentials
$PrinterFullInfo = Get-Printer -CimSession $Session -Name $PrinterName -Full
$WsdPortName = $PrinterFullInfo.PortName
$PortFullInfo = Get-PrinterPort -Name $WsdPortName -CimSession $Session | Select-Object * 
$IpPrinter = ($PortFullInfo.DeviceURL -split '/')[2]
$ConnectResult = Test-Connection -ComputerName $IpPrinter -Count 1 -Quiet

[PSCustomObject]@{
    PrinterName = $PrinterName
    IPAddress   = $IpPrinter
    PingTest    = $ConnectResult
    WSDPortName = $WsdPortName
}