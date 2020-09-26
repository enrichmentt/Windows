function Test-Port
{
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
        foreach ($P in $Port)
        {
            if ($Tcp)
            {
                $Type = 'TCP'
                $TcpClient = [System.Net.Sockets.TcpClient]::new()
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
                $UdpClient = [System.Net.Sockets.UdpClient]::new()
                $UdpClient.client.ReceiveTimeout = $Timeout 
                $UdpClient.Connect("$Dest", $P) 
                $Text = new-object System.Text.AsciiEncoding 
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
                        if (Test-Connection -comp $Dest -count 1 -quiet)
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
                Notes       = $Notes
            }
        }
    }
}