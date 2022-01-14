# https://github.com/pisinger

<#	
	With that script you could do your latency checks natively in PowerShell instead of leveraging psping, which might be more helpful when running it from Linux-based edge devices. It again connects to the endpoints specified in $endpoints hash table. You can also specify different ports to be used by just adding the desired port as :5061 or :80.
	
	It does now also provide limited proxy support - so when you have the requirement to use a proxy to connect to the internet, then try to run the script together with the $Proxy switch.
	
	By default it will make 4 consequent TCP connects to grab average timings (at least 3 connect attempts required) - you can adjust this by changing $iterations param. Beside of AVG it will give you also the MIN and MAX latency value - for the average the lowest and highest value will be excluded.

	EXAMPLE: 
		.\measure-latency-to-azure-endpoints-via-dotnet.ps1 | ft
		.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -Iterations 10
		.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -Proxy -Iterations 5
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
	[int]$Port = 443,
	[switch]$Proxy
)

Add-Type -AssemblyName System.Net.http

$Endpoints = @{
    "US Central"		= "https://speedtestcus.blob.core.windows.net/cb.json"
	"US North Central" 	= "https://speedtestnsus.blob.core.windows.net/cb.json"
    "US South Central"	= "https://speedtestscus.blob.core.windows.net/cb.json"	
	"US West Central"	= "https://speedtestwestcentralus.blob.core.windows.net/cb.json"
	"US West" 			= "https://speedtestwus.blob.core.windows.net/cb.json"
    "US East"			= "https://speedtesteus.blob.core.windows.net/cb.json"
    "Europe West"		= "https://speedtestwe.blob.core.windows.net/cb.json"
    "Europe North"		= "https://speedtestne.blob.core.windows.net/cb.json"
    "Asia Southeast"	= "https://speedtestsea.blob.core.windows.net/cb.json"
    "Asia East"			= "https://speedtestea.blob.core.windows.net/cb.json"
    "Japan East"		= "https://speedtestjpe.blob.core.windows.net/cb.json"
    "Japan West"		= "https://speedtestjpw.blob.core.windows.net/cb.json"
    "Brazil South"		= "https://speedtestbs.blob.core.windows.net/cb.json"
    "UK West"			= "https://speedtestukw.blob.core.windows.net/cb.json"
    "UK South"			= "https://speedtestuks.blob.core.windows.net/cb.json"
    "Canada Central"	= "https://speedtestcac.blob.core.windows.net/cb.json"
    "Canada East"		= "https://speedtestcae.blob.core.windows.net/cb.json"
	"Switzerland North"	= "https://speedtestchn.blob.core.windows.net/cb.json"
	"Switzerland West"	= "https://speedtestchw.blob.core.windows.net/cb.json"
	"India Central"		= "https://speedtestcentralindia.blob.core.windows.net/cb.json"
	"India West"		= "https://speedtestwestindia.blob.core.windows.net/cb.json"
	"India East"		= "https://speedtesteastindia.blob.core.windows.net/cb.json"
	"France Central"	= "https://speedtestfrc.blob.core.windows.net/cb.json"
	"Germany North"		= "https://speedtestden.blob.core.windows.net/cb.json"
	"Korea Central"		= "https://speedtestkoreacentral.blob.core.windows.net/cb.json"
	"Korea South"		= "https://speedtestkoreasouth.blob.core.windows.net/cb.json"
	"UAE North"			= "https://speedtestuaen.blob.core.windows.net/cb.json"
	"Brazil East"		= "https://speedtestnea.blob.core.windows.net/cb.json"
	"AUS East"			= "https://speedtestoze.blob.core.windows.net/cb.json"
	"AUS Southeast"		= "https://speedtestozse.blob.core.windows.net/cb.json"
	"South Africa North"= "https://speedtestsan.blob.core.windows.net/cb.json"
}

#----------------------------------
# run connects in parallel
$LatencyCheck = $Endpoints.GetEnumerator() | FOREACH-OBJECT -parallel {
	
	$i = 0
	[System.Collections.ArrayList]$Timings = @()
	
	IF ($using:Proxy) {
		
		$Endpoint = $_.value
		$Region = $_.name
		
		try {			
			$HttpClient = New-Object System.Net.http.HttpClient
			$StopWatch = New-Object System.Diagnostics.Stopwatch
			
			# iterations +1 as first connect is been used as warmup/setup
			while ($i -lt $($using:Iterations + 1)) {
				$StopWatch.Restart()
				$result = $HttpClient.GetStringAsync($Endpoint) | Select Result, IsCompletedSuccessfully
				# add/save timings for each iteration -> to calc avg
				$Timings.add([math]::round($StopWatch.Elapsed.TotalMilliseconds)) | out-null
				
				# check if failed
				IF ($result.IsCompletedSuccessfully -ne $true){ break }
				$i++
			}
			
			$HttpClient.Dispose()
		}
		catch {
			$result = "False"
			
			write-error $_.Exception.Message
			($global:error[0].exception.response)
		}
		finally {
			# remove first warmup/setup connect
			$Timings.remove($Timings[0])
			
			# check if timings is not null - RTTAvg does have highest and lowest value excluded
			IF (($Timings)) { $RTTAvg = [math]::round( (($timings | Sort-Object -Descending)[1..$($timings.count - 2)] | Measure-Object -Average).Average) }
			ELSE { $RTTAvg = "" }
			
			$obj = [PSCustomObject]@{
				Region 		= $Region
				Endpoint 	= $Endpoint
				Success		= $result.IsCompletedSuccessfully
				RTTMin		= ($Timings | Measure-Object -Min).Minimum
				RTTAvg		= $RTTAvg
				RTTMax		= ($Timings | Measure-Object -Max).Maximum
				RTTs 		= $Timings
			}
		}
	}
	ELSE {	
		# remove any http:// and /paths
		$Endpoint = (($_.value -split "\/\/",2)[1] -split "\/",2)[0]
		$Region = $_.name
		
		# check for custom port in $endpoints
		IF ($Endpoint -match ":") {
			$Port = $Endpoint.Split(":",2)[1]
			$Endpoint = $Endpoint.Split(":",2)[0]
		}
		ELSE {
			$Port = $using:Port
		}
		
		try {
			# check first if dns/endpoint exists
			IF ( $DnsName = Resolve-DnsName $Endpoint -ErrorAction SilentlyContinue) {
				# for any endpoint do it multiple times to calc some avg
				# iterations +1 as first connect is been used as warmup
				while ($i -lt $($using:Iterations + 1)) {
					$TcpSocket = New-Object System.Net.Sockets.Socket([System.Net.Sockets.SocketType]::Stream,[System.Net.Sockets.ProtocolType]::Tcp)
					$TcpSocket.NoDelay = $true
					
					# add/save timings for each iteration -> to calc avg
					$Timings.add([math]::round( (Measure-Command { $TcpSocket.Connect($Endpoint, $Port) }).TotalMilliseconds)) | out-null
					$IpAddr = (($TcpSocket.RemoteEndPoint -split "fff:",2)[1] -split "]",2)[0]
					$result = $TcpSocket.Connected
					
					# release/close
					$TcpSocket.Dispose()
					$i++
				}
			}
		}
		catch{
			$result = $TcpSocket.Connected
			$TcpSocket.Dispose()
			
			write-error $_.Exception.Message
			($global:error[0].exception.response)
		}
		finally{
			# remove first warmup connect
			$Timings.remove($Timings[0])
			
			# dns error
			if (-not($DnsName)) { $DnsName = ""; $result = "DnsFailure"}
			else { $DnsName = ((($DnsName | where-object QueryType -eq A).Name | select -First 1) -split '\.')[0..1] }
			
			# check if timings is not null - RTTAvg does have highest and lowest value excluded
			IF (($Timings)) { $RTTAvg = [math]::round( (($timings | Sort-Object -Descending)[1..$($timings.count - 2)] | Measure-Object -Average).Average)	}
			ELSE { $RTTAvg = "" }
			
			$obj = [PSCustomObject]@{
				Region 		= $Region
				Endpoint 	= $Endpoint
				Port		= $Port
				Success		= $result
				DnsName1	= $DnsName[0]
				DnsName2	= $DnsName[1]
				RTTMin		= ($Timings | Measure-Object -Min).Minimum
				RTTAvg		= $RTTAvg
				RTTMax		= ($Timings | Measure-Object -Max).Maximum
				RTTs 		= $Timings
				IPAddr		= $IpAddr
			}
		}
	}
	return $obj
} -ThrottleLimit 30

#----------------------------------
# return output or export to csv
IF ($ExportToCsv){	
	$LatencyCheck | Sort-Object Endpoint | Select-Object Region, Endpoint, Port, Success, DnsName1, DnsName2, RTTMin, RTTAvg, RTTMax, IpAddr | export-Csv $CsvFilepath -Append
}
ELSE {
	$LatencyCheck = $LatencyCheck | Sort-Object RTTMin
	$LatencyCheck
}
