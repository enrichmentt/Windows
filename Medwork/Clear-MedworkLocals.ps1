<#

    Очистка C:\Medwork3\LOCALS
    если файлов .mdb >2
    (C) 2024 Ilnazier

#>

$ProcessName = "Medwork"
$RootPath = "C:\Medwork3\"
$LocalsPath = [System.IO.Path]::Combine($RootPath, "LOCALS")
$ThresholdForDeletingFiles = 2
$LogFilePath = "C:\Windows\Temp\Clear-MedworkLocals.txt"
$DateFormat = "yyyy-MM-dd HH:mm:ss"


if (-not (Test-Path -Path $RootPath))
{
    $date = Get-Date -Format $DateFormat
    "[$date] Path $RootPath not found." | Out-File -FilePath $LogFilePath -Encoding utf8 -Append
    break
}

if ($null -ne (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue))
{
    $date = Get-Date -Format $DateFormat
    "[$date] Process $ProcessName run. Script break." | Out-File -FilePath $LogFilePath -Encoding utf8 -Append
    break
}



$CountFilesInDirLocals = (Get-ChildItem -Path $LocalsPath -Filter "*.mdb").Count

$date = Get-Date -Format $DateFormat
"[$date] Count .mdb files in $LocalsPath = $CountFilesInDirLocals." | Out-File -FilePath $LogFilePath -Encoding utf8 -Append


if ($CountFilesInDirLocals -gt $ThresholdForDeletingFiles)
{
    $date = Get-Date -Format $DateFormat
    "[$date] Remove $LocalsPath" | Out-File -FilePath $LogFilePath -Encoding utf8 -Append

    Remove-Item -Path $LocalsPath -Force -Recurse
}



$LengthLogFile = (Get-ChildItem -Path $LogFilePath).Length
if ($LengthLogFile -ge 1000000)
{
    Remove-Item $LogFilePath -Force

    $date = Get-Date -Format $DateFormat
    "[$date] Remove $LogFilePath" | Out-File -FilePath $LogFilePath -Encoding utf8 -Append
}
