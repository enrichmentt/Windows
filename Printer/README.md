# Скрипты для работы с принтерами и принт-сервером.





##### Get-IpAddressWsdPort.ps1 

Узнать IP адрес порта, если принтер настроен через WSD порт

```
.\Get-IpAddressWsdPort.ps1 -ComputerName $Printserver -PrinterName $PrinterName


.\Get-IpAddressWsdPort.ps1 -ComputerName prn-01 -PrinterName r-prn110 -Credentials med\vapekshev-adm
PrinterName IPAddress    PingTest WSDPortName
----------- ---------    -------- -----------
r-prn110    10.100.36.67     True WSD-64028885-4f92-4f92-b754-e514618c0353.0038

```

