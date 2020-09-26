function Get-FreeSpace
{
        [CmdletBinding()]
        param (
                [string]$Disk = '*',

                [Parameter(Position=0)]
                [string[]]$ComputerName = $env:COMPUTERNAME,

                [PSCredential]$Credential
        )

        $result = @()
        if ($Credential)
        {
                $cred = Get-Credential $Credential
        }

        foreach ($Comp in $ComputerName)
        {
                try
                {
                        if ($Disk -ne '*')
                        {
                                $diskName = [string]::Concat($Disk[0], ":")
                                $DisksInfo = Get-WmiObject "Win32_LogicalDisk" -ComputerName $Comp -Credential $cred -ErrorAction "Stop" | Where-Object { $_.DeviceID -eq $diskName }

                                if (-not $DisksInfo)
                                {
                                        Write-Warning -Message "Disk not found"
                                        continue
                                }
                        }
                        elseif ($Disk -eq '*')
                        {
                                $DisksInfo = Get-WmiObject "Win32_LogicalDisk" -ComputerName $Comp -Credential $cred -ErrorAction "Stop"
                        }
                }
                catch
                {
                        Write-Host $_
                        continue
                }



                foreach ($DiskInfo in $DisksInfo)
                {
                        try
                        {
                                $FreeSpacePercent = (100 - (($DiskInfo.Size - $DiskInfo.FreeSpace) * 100) / $DiskInfo.Size)
                        }
                        catch
                        {
                                Write-Host $_
                                continue
                        }

                        $ResultFreeSpace = [System.Math]::Round($FreeSpacePercent, 1)
         
                        $obj = New-Object PSObject
                        $obj | Add-Member -MemberType "NoteProperty" -Name "ComputerName" -Value $Comp
                        $obj | Add-Member -MemberType "NoteProperty" -Name "DiskName" -Value $DiskInfo.DeviceID
                        $obj | Add-Member -MemberType "NoteProperty" -Name "FreeSpace %" -Value $ResultFreeSpace

                
                        if ($DiskInfo.FreeSpace / [System.Math]::Pow(1024, 3) -lt 1)
                        {
                                $Free = $DiskInfo.FreeSpace / [System.Math]::Pow(1024, 2)
                                $Free = [System.Math]::Round($Free, 1)
                                $Free = [string]::Concat($Free, 'Mb')
                                $obj | Add-Member -MemberType NoteProperty -Name "FreeSpace" -Value $Free
                        }
                        elseif ($DiskInfo.FreeSpace / [System.Math]::Pow(1024, 3) -lt 999)
                        {
                                $Free = $DiskInfo.FreeSpace / [System.Math]::Pow(1024, 3)
                                $Free = [System.Math]::Round($Free, 1)
                                $Free = [string]::Concat($Free, 'Gb')
                                $obj | Add-Member -MemberType NoteProperty -Name "FreeSpace" -Value $Free
                        }
                        elseif ($DiskInfo.FreeSpace / [System.Math]::Pow(1024, 3) -gt 1000)
                        {
                                $Free = $DiskInfo.FreeSpace / [System.Math]::Pow(1024, 4)
                                $Free = [System.Math]::Round($Free, 1)
                                $Free = [string]::Concat($Free, 'Tb')
                                $obj | Add-Member -MemberType NoteProperty -Name "FreeSpace" -Value $Free
                        }

                        $result += $obj
                }
        }

        if ($result)
        {
                return $result
        }
}