function Test-Port
{
    <#
    .SYNOPSIS
    Проверка доступности порта

    .DESCRIPTION
    Проверка доступности порта TCP или UPD

    .PARAMETER Destination
    Цель

    .PARAMETER Port
    Номер порта

    .PARAMETER Timeout
    Время ожидания

    .PARAMETER Tcp
    Tcp

    .PARAMETER Udp
    Udp

    .EXAMPLE
    Test-Port -Destination 8.8.8.8 -Port 53
    Проверка порта 53 TCP

    .EXAMPLE
    Test-Port -Destination 8.8.8.8 -Port 53 -Udp
    Проверка порта 53 UDP

    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string[]]$Destination,

        [Parameter(Position = 1, Mandatory = $true)]
        [int[]]$Port,

        [int]$Timeout = 5000,

        [switch]$Tcp,

        [switch]$Udp
    )

    if (-not ($Tcp -and $Udp))
    {
        $Tcp = $true
    }


    foreach ($Dest in $Destination)
    {
        $Ping = Test-Connection $Dest -Count 1 -ErrorAction Ignore

        if($null -eq $Ping){
            $PingResult = $false
        }else{
            $PingResult = $true
        }

        foreach ($P in $Port)
        {
            if ($Tcp)
            {
                $Type = 'TCP'
                $TcpClient = New-Object System.Net.Sockets.TcpClient
                try
                {
                    $Connect = $TcpClient.BeginConnect($Dest, $P, $null, $null)
                    $Wait = $Connect.AsyncWaitHandle.WaitOne($Timeout, $false)

                    if (!$Wait)
                    {
                        $Open = $false
                        $Notes = "Connection time out"
                    }
                    else
                    {
                        try
                        {
                            $TcpClient.EndConnect($Connect)
                            $Open = $true
                            $Notes = ""
                        }
                        catch
                        {
                            $Open = $false
                            $Notes = $_.Exception.InnerException.Message
                        }
                    }
                }
                catch {}
                $TcpClient.Close()
            }

            if ($Udp)
            {
                $Type = 'UDP'
                $UdpClient = New-Object System.Net.Sockets.UdpClient
                $UdpClient.client.ReceiveTimeout = $Timeout
                $UdpClient.Connect("$Dest", $P)
                $Text = New-Object System.Text.AsciiEncoding
                $byte = $Text.GetBytes("$(Get-Date)")
                [void]$UdpClient.Send($byte, $byte.length)
                $RemoteEndpoint = New-Object system.net.ipendpoint([system.net.ipaddress]::Any, 0)

                Try
                {
                    $ReceiveBytes = $UdpClient.Receive([ref]$RemoteEndpoint)
                    [string]$ReturnData = $a.GetString($ReceiveBytes)

                    if ($ReturnData)
                    {
                        $Open = $true

                        $UdpClient.close()
                    }
                }
                catch
                {
                    if ($_.ToString() -match "\bRespond after a period of time\b")
                    {
                        $UdpClient.Close()
                        if (Test-Connection -comp $Dest -Count 1 -Quiet)
                        {
                            $Open = $True
                            $Notes = ""
                        }
                        else
                        {
                            $Open = $False
                            $Notes = "Unable to verify if port is open or if host is unavailable."
                        }
                    }
                }
            }

            [PSCustomObject]@{
                Destination = $Dest
                Port        = $P
                Type        = $Type
                Open        = $Open
                Ping        = $PingResult
                Notes       = $Notes
            }
        }

        $Ping = $null
    }
}
