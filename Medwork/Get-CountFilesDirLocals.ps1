<#

    Количество файлов в папке C:\Medwork3\LOCALS

#>

#[string[]]$Computers = "R-W-IB-136593", "R-W-IB-142225", "VICTOR-IB-W11"
[string[]]$Computers = Get-ADComputer -SearchBase "OU=IB,OU=Rublevskoe,OU=Workstations,DC=med,DC=bakulev,DC=ru" -Filter * -Properties OperatingSystem, LastLogonDate | Where-Object { $_.OperatingSystem -like "*Windows*" -and $_.LastLogonDate -gt (Get-Date).AddDays(-200) } |  Select-Object -ExpandProperty name

$Result = @()
$RootPath = "C:\Medwork3\"
$LocalsPath = [System.IO.Path]::Combine($RootPath, "LOCALS")


foreach ($_ in $Computers)
{
    if (Test-Connection -ComputerName $_ -Quiet -Count 2)
    {
        if (Test-Path -Path $RootPath)
        {           
            $LocalsPathCurrentComputer = $LocalsPath.Replace("C:\", "\\$_\C$\")
            $CountFilesInDirLocals = (Get-ChildItem -Path $LocalsPathCurrentComputer -Filter "*.mdb").Count
            Write-Host $_ - $CountFilesInDirLocals -ForegroundColor Yellow
            
            $Result += [PSCustomObject]@{
                ComputerName          = $_
                CountFilesInDirLocals = $CountFilesInDirLocals
            }
        }
    }
}

$Result | Sort-Object CountFilesInDirLocals -Descending | Out-File .\result.txt 
