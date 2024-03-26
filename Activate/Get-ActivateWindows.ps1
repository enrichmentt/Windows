param (
	[string[]]$Comps
)

#$Ou = "OU=Leninskiy,OU=Workstations,DC=med,DC=bakulev,DC=ru"
#$Ou = "OU=Rublevskoe, OU=Workstations, DC=med, DC=bakulev, DC=ru"
#$Comps = Get-ADComputer -SearchBase $Ou -Filter { OperatingSystem -like '*10*' } -Properties OperatingSystem | Select-Object Name, OperatingSystem 
$KmsServer = "kms.med.bakulev.ru"

foreach ($Comp in $Comps)
{
    $CompName = $Comp

    #Write-Host $CompName -ForegroundColor Green

    if (Test-Connection -ComputerName $CompName -Quiet -Count 1)
    {
        switch ($Comp.OperatingSystem)
        {
            "Windows 10 Pro" { $Key = "W269N-WFGWX-YVC9B-4J6C9-T83GX" }
            "Windows 10 Корпоративная" { $Key = "NPPR9-FWDCX-D2C8J-H872K-2YT43" }
            "Windows 10 для образовательных учреждений" { $Key = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2" }
            "Windows 10 Корпоративная LTSC" { $Key = "DCPHK-NFMTC-H88MJ-PFHPY-QJ4BJ" }
        }

        $KeyResult = cscript.exe c:\windows\system32\slmgr.vbs $CompName /ipk $Key
        $ServerResult = cscript.exe c:\windows\system32\slmgr.vbs $CompName /skms $KmsServer
        $Result = cscript.exe c:\windows\system32\slmgr.vbs $CompName /ato 

        if ($Result[4] -eq "Активация выполнена успешно.")
        {
            $Result = "Активация выполнена успешно."
        }
        else
        {
            $Result = "необходимо проверить результат активации."
        }

        [PSCustomObject]@{
            ComputerName  = $CompName
            KeyInstalled  = $KeyResult[3].Split(':')[1].Trim()
            KmsServerName = $ServerResult[3].Split(':')[1].Trim()
            Result        = $Result
        }
    }
}