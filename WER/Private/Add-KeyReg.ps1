function Add-KeyReg
{
    param (
        [Parameter(Mandatory = $false)]
        [string] $HKLM = "2147483650",

        [Parameter(Mandatory = $true)]
        [string] $KeyName,

        $ObjectReg
    )

    try
    {
        $returnLocalDump = $ObjectReg.EnumKey($HKLM, $KeyName)
        if ($returnLocalDump.ReturnValue -ne 0)
        {
            $createKeyName = $ObjectReg.CreateKey($HKLM, $KeyName)
            if ($createKeyName.ReturnValue -eq 0)
            {
                Write-Host "$KeyName create on $server" -ForegroundColor Green
            }
            else
            {
                Write-Host "Dont create key $KeyName on $server return value is $($createKeyName.ReturnValue)"
            }
        }
    }
    catch
    {
        Write-Host $_ -ForegroundColor Red
    }
}
