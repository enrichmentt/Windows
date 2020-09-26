# Get-FreeSpace

Getting free space on server(s)

## Get Started

```powershell
Import-Module .\Get-FreeSpace.ps1
```

## Examples

```powershell
Get-FreeSpace -ComputerName ServerName - -Disk C:\
```

```powershell
Get-FreeSpace -ComputerName ServerName -Disk C:\ -Credential UserName
```