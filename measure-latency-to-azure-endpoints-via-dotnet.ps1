# https://github.com/pisinger

<#
	As latency is the new cloud currency I decided to create a PowerShell script which does make use of PSPING to do latency checks. 
	This script here is doing the same but this time natively via .NET what makes it more helpful to run it from Linux-based edge devices.
	
	By default it will make 4 consequent TCP connects to grab average timings. You can adjust this by changing "iterations" param.

	EXAMPLE: 
		.\measure-latency-to-azure-endpoints-via-dotnet.ps1
		.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -Iterations 10
		.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -ExportToCsv
		.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -ExportToCsv -CsvFilepath c:\temp\results.txt
#>

[CmdletBinding()]
param(
	[switch]$ExportToCsv,
	[string]$CsvFilepath = $($PSScriptRoot + "\measure-latency-to-azure-results.csv"),
	[ValidateRange(3,10)]
	[int]$Iterations = 4,
	[ValidateRange(1,65535)]
	[int]$Port = 443
)

$Endpoints = @{
    "US Central"		= "speedtestcus.blob.core.windows.net"
	"US North Central" 	= "speedtestnsus.blob.core.windows.net"
    "US South Central"	= "speedtestscus.blob.core.windows.net"	
	"US West Central"	= "speedtestwestcentralus.blob.core.windows.net"
	"US West" 			= "speedtestwus.blob.core.windows.net"
    "US East"			= "speedtesteus.blob.core.windows.net"
    "Europe West"		= "speedtestwe.blob.core.windows.net"
    "Europe North"		= "speedtestne.blob.core.windows.net"
    "Asia Southeast"	= "speedtestsea.blob.core.windows.net"
    "Asia East"			= "speedtestea.blob.core.windows.net"
    "Japan East"		= "speedtestjpe.blob.core.windows.net"
    "Japan West"		= "speedtestjpw.blob.core.windows.net"
    "Brazil South"		= "speedtestbs.blob.core.windows.net"
    "UK West"			= "speedtestukw.blob.core.windows.net"
    "UK South"			= "speedtestuks.blob.core.windows.net"
    "Canada Central"	= "speedtestcac.blob.core.windows.net"
    "Canada East"		= "speedtestcae.blob.core.windows.net"
	"Switzerland North"	= "speedtestchn.blob.core.windows.net"
	"Switzerland West"	= "speedtestchw.blob.core.windows.net"
	"India Central"		= "speedtestcentralindia.blob.core.windows.net"
	"India West"		= "speedtestwestindia.blob.core.windows.net"
	"India East"		= "speedtesteastindia.blob.core.windows.net"
	"France Central"	= "speedtestfrc.blob.core.windows.net"
	"Germany North"		= "speedtestden.blob.core.windows.net"
	"Korea Central"		= "speedtestkoreacentral.blob.core.windows.net"
	"Korea South"		= "speedtestkoreasouth.blob.core.windows.net"
	"UAE North"			= "speedtestuaen.blob.core.windows.net"
	"Brazil East"		= "speedtestnea.blob.core.windows.net"
	"AUS East"			= "speedtestoze.blob.core.windows.net"
	"AUS Southeast"		= "speedtestozse.blob.core.windows.net"
	"South Africa North"= "speedtestsan.blob.core.windows.net"
}

#----------------------------------
# run connects in parallel
$LatencyCheck = $Endpoints.GetEnumerator() | FOREACH-OBJECT -parallel {

    $Endpoint = $_.value
	$Region = $_.name
	$i = 0	
	[System.Collections.ArrayList]$Timings = @()
	
	# check first if dns/endpoint exists
	IF ( $DnsName = Resolve-DnsName $Endpoint -ErrorAction SilentlyContinue) {	
		try {
			# for any endpoint do it multiple times to calc some avg
			# iterations +1 as first connect is been used as warmup
			while ($i -lt $($using:Iterations + 1)) {
				$TcpSocket = New-Object System.Net.Sockets.Socket([System.Net.Sockets.SocketType]::Stream,[System.Net.Sockets.ProtocolType]::Tcp)
				$TcpSocket.NoDelay = $true
				
				# add/save timings for each iteration -> to calc avg
				$Timings.add([math]::round((Measure-Command { $TcpSocket.Connect($Endpoint, $using:Port) }).TotalMilliseconds))	| out-null
				$IpAddr = (($TcpSocket.RemoteEndPoint -split "fff:",2)[1] -split "]",2)[0]
				
				# release/close
				$TcpSocket.Dispose()
				$i++
			}
		}
		catch{
			write-host $_.Exception.Message
			($global:error[0].exception.response)
		}
		finally{
			# remove first warmup connect
			$Timings.remove($Timings[0])
			
			# check if timings is not null
			IF (($Timings)) {
				# RTTAvg does have highest and lowest value excluded
				$RTTAvg = [math]::round( (($timings | sort -Descending)[1..$($timings.count - 2)] | Measure-Object -Average).Average)
			}
			ELSE {
				$RTTAvg = ""
			}			
			
			$obj = [PSCustomObject]@{				
				Region 		= $Region
				Endpoint 	= $Endpoint
				DnsName		= ($DnsName.NameHost -split '\.')[1]
				RTTMin		= ($Timings | Measure-Object -Min).Minimum
				RTTAvg		= $RTTAvg
				RTTMax		= ($Timings | Measure-Object -Max).Maximum
				RTTs 		= $Timings
				IPAddr		= $IpAddr
			}
			$TcpSocket.Dispose()
		}
	}
	ELSE {
		$obj = [PSCustomObject]@{				
			Region 		= $Region
			Endpoint 	= $Endpoint
			DnsName		= "NOT FOUND"
			RTTMin		= ""
			RTTAvg		= ""
			RTTMax		= ""
			RTTs 		= @()
			IPAddr		= ""
		}
	}
	
	return $obj
} -ThrottleLimit 30

#----------------------------------
# return output or export to csv
IF ($ExportToCsv){	
	$LatencyCheck | Sort-Object Endpoint | Select-Object Region, Endpoint, DnsName, RTTMin, RTTAvg, RTTMax, IpAddr | export-Csv $CsvFilepath -Append
}
ELSE {
	$LatencyCheck | Sort-Object RTTMin | FT
}
