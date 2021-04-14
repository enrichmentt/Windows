Get-ChildItem $PSScriptRoot | Unblock-File
Get-ChildItem $PSScriptRoot\*.ps1 | ForEach-Object {. $_.FullName}

Export-ModuleMember -Function *
