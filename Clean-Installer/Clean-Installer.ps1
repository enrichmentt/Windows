Function Clean-Up ([String]$FileType, [Array]$Data)
{
      #Список файлов в каталоге C:\Windows\Installer.
      $InstallerFiles = Get-ChildItem "C:\Windows\Installer" "*.$FileType"
      $Length = 0

      foreach ($InstallerFile in $InstallerFiles)
      {
            #Если Windows Installer не имеет данных об файлах в C:\windows\Installer - удаляем
            If (!($Data | Where-Object { $_ -eq $InstallerFile.FullName }))
            {
                  $Length += $InstallerFile.Length
                  Write-Host "Remove file $($InstallerFile.FullName)" -ForegroundColor Yellow
                  Remove-Item -Path $InstallerFile.FullName -Force -ErrorAction Continue
            }
      }


      $str = "Length $FileType : {0:N0}" -f $Length
      Write-Host $str

}

[array]$PatchesLocation = @()
[array]$InstallersLocation = @()


#Поиск установленных программ
$Installer = New-Object -ComObject "WindowsInstaller.Installer"
$Type = $Installer.GetType()
$Products = $Type.InvokeMember('Products', [System.Reflection.BindingFlags]::GetProperty, $null, $Installer, $null)

#Просмотр установленных патчей для программ
foreach ($ProductCode in $Products)
{
    $InstallersLocation += $Installer.GetType().InvokeMember("ProductInfo","GetProperty",$null, $Installer, @($ProductCode, "LocalPackage"))
    
    
    #Поиск патчей для отдельного пакета
    $Patches = $Installer.GetType().InvokeMember("Patches","GetProperty",$null, $Installer, @($ProductCode, "LocalPackage"))

    foreach ($PatchCode in $Patches)
    {
        $PatchesLocation += $Installer.GetType().InvokeMember("PatchInfo","GetProperty",$null, $Installer, @($PatchCode, "LocalPackage"))
    }
}

#Сравниваем данных с файлами в C:\windows\installer с последующим удалением
If ( $PatchesLocation.Count -ne 0)
{
    Clean-Up -FileType "msp" -Data $PatchesLocation
}
If ( $InstallersLocation.Count -ne 0)
{
    Clean-Up -FileType "msi" -Data $InstallersLocation
}