<#
.Synopsis

Firebuster is a PowerShell script for egress testing. Firebuster will allow you to see if 
the firewall has proper egress filtering (i.e. outbound traffic is controlled or not). This
will help towards identifying a port for backdoor.

Author: Nikhil Sreekunar (@roo7break)
License: GNU GPL v2
Version: v1.0

.Description
FireBuster was inspired by Dave Rel1k's egressbuster which can be found [here](https://www.trustedsec.com/february-2012/new-tool-release-egress-buster-find-outbound-ports/)

Dave's program involves either running a Python script or an executable. However, what if your
victim's machine does not have Python installed or has restrictions on running executables? These
were the reasons which prompted me to write a script in PowerShell.

.Usage
.\FireBuster.ps1 <listening_server_ip> <port range>

.Example
.\FireBuster.ps1 10.10.10.10 100-500

.Links
http://roo7break.co.uk
https://www.trustedsec.com/february-2012/new-tool-release-egress-buster-find-outbound-ports/
#>

Param( [Parameter(Position = 0, Mandatory = $True)] [String] $targetip = $(throw "Please specify an EndPoint (Host or IP Address)"),
       [Parameter(Position = 1, Mandatory = $False)] [String] $portrange = "1-65535")

function FireBuster{
    
    [int] $lowport = $portrange.split("-")[0]
    [int] $highport = $portrange.split("-")[1]
	
    $hostaddr = [system.net.IPAddress]::Parse($targetip)
    
    $ErrorActionPreference = 'SilentlyContinue'
    if ($verbose){ write-host "Trying to connect to $hostaddr from $lowport to $highport" }
	[int] $ports = 0
	Write-host "Sending...."
	for($ports=$lowport; $ports -le $highport ; $ports++){
        try{
            $Socket = New-Object System.Net.Sockets.TCPClient($hostaddr,$ports)
			$Stream = $Socket.GetStream()
			$Writer = New-Object System.IO.StreamWriter($Stream)
			$Writer.AutoFlush = $true
			$Writer.NewLine = $true
			$Writer.Write("$ports")
			$Socket.Close()
        }catch { Write-Error $Error[0]}
    }        
	Write-Host "Data sent to all ports"
}

FireBuster
