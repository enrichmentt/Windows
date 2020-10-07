function Add-CollectWerDump
{
    [CmdletBinding()]
    param (
        [string]
        $Process,

        [string[]]
        $ComputerName = $env:COMPUTERNAME,

        [string]
        $DumpFolder = "C:\Dumps\",

        [int]
        $DumpCount,

        [PScredential]
        $Credential
    )

    if($Credential)
    {
        $cred = $Credential
    }

    foreach ($Comp in $ComputerName)
    {
        try
        {
            $objReg = Get-WmiObject -ComputerName $Comp -Credential $cred -Namespace "root\default" -List | Where-Object {$_.Name -eq "StdRegProv"} -ErrorAction Stop
        }
        catch
        {
            Write-Host $_
        }

        $keyName = "SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\"
        $subKeyName = [System.String]::Concat($keyName, $Process)

        Add-KeyReg -ObjectReg $objReg -KeyName $keyName
        Add-KeyReg -ObjectReg $objReg -KeyName $subKeyName

        Add-ValueReg -ObjectReg $objReg -SubKeyName $keyName -DumpFolder $DumpFolder
        Add-ValueReg -ObjectReg $objReg -SubKeyName $subKeyName -DumpFolder $DumpFolder
    }
}
