function Add-ValueReg
{
    [CmdletBinding()]
    param
    (
        [byte] $DumpType = [System.Convert]::ToByte(2),

        [Parameter(Mandatory=$true)]
        [string] $DumpFolder,

        [byte] $DumpCount = [System.Convert]::ToByte(10),

        [Parameter(Mandatory = $false)]
        [string] $HKLM = "2147483650",

        [Parameter(Mandatory = $true)]
        [string] $SubKeyName,

        [parameter(Mandatory = $true)]
        $ObjectReg
    )


    try
    {
        $returnDumpCount = $ObjectReg.SetDWORDValue($HKLM, $SubKeyName, "DumpCount", $DumpCount)
        $returnDumpFolder = $ObjectReg.SetExpandedStringValue($HKLM, $SubKeyName, "DumpFolder", $DumpFolder)
        $returnDumpType = $ObjectReg.SetDWORDValue($HKLM, $SubKeyName, "DumpType", $DumpType)

        if ($returnDumpCount.ReturnValue -eq 0 -and $returnDumpFolder.ReturnValue -eq 0 -and $returnDumpType.ReturnValue -eq 0)
        {
            Write-Host "Настройка дампов в `"$SubKeyName`" на $server успешно завершено" -ForegroundColor Green
        }
        else
        {
            Write-Host "Dont create values on $server return value is $($returnDumpCount.ReturnValue)"
        }
    }
    catch
    {
        Write-Host $_ -ForegroundColor Red
    }
}
