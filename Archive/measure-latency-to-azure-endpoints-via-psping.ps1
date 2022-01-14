# https://github.com/pisinger

<#
	As latency is the new cloud currency I decided to create a PowerShell script which does make use of PSPING to do latency checks. 
	In fact, this script does leverage PSPING for checking latency by doing TCP handshakes to the endpoints specified in $endpoints hash table
	
	By default it will trigger PSPING to make 3 TCP connects and will then simply grab the average timings provided by psping.

	The script will also auto-download psping if not yet exists in script folder.
	PSPING: https://docs.microsoft.com/en-us/sysinternals/downloads/psping

	EXAMPLE: 
		.\measure-latency-to-azure-endpoints-via-psping.ps1
		.\measure-latency-to-azure-endpoints-via-psping.ps1 -ExportToCsv
		.\measure-latency-to-azure-endpoints-via-psping.ps1 -ExportToCsv -CsvFilepath c:\temp\results.txt
#>

param(
	[switch]$ExportToCsv,
	[string]$CsvFilepath = $($PSScriptRoot + "\measure-latency-to-azure-results.csv")
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
# download psping if not yet exists
IF (-not(Get-Item $($PSScriptRoot + "\psping.exe") -ErrorAction SilentlyContinue)) {
	Invoke-WebRequest -Method Get -Uri "http://live.sysinternals.com/psping.exe" -Outfile $($PSScriptRoot + "\psping.exe")
}

#----------------------------------
# run psping in parallel
$LatencyCheck = $Endpoints.GetEnumerator() | FOREACH-OBJECT -parallel {

    $Endpoint = $_.value
	$Region = $_.name
	$Iteration = 3

    $command = '.\psping.exe -n '+ $Iteration + ' ' + $Endpoint + ":443"
	$RTT = Invoke-Expression $command -ErrorAction Continue
	
	# check for psping success and take average
	IF ($RTT -like "*100% loss*") {
		$RTT = 0
		$IPAddr = "connect failed"
	}
	ELSEIF ($RTT -like "*average*"){
		$RTT = ($RTT | where {$_ -like "*minimum*"}).Split(',')[0] 
		$RTT = ($RTT.Split('=')[1]).Replace(' ','')
		$RTT = [double]$RTT.Split('ms')[0]
		$IPAddr = (Resolve-DnsName $Endpoint | ? {$_.Type -eq "A"}).IpAddress
	}
	ELSE {
		$RTT = 0
		$IPAddr = "host not found"	
	}
	
    $obj = [PSCustomObject]@{				
		Region 		= $Region
		Endpoint 	= $Endpoint
		DnsName		= ((Resolve-DnsName $Endpoint).NameHost -split '\.')[1]
		RTT 		= $RTT
		IPAddr		= $IPAddr		
	}

	return $obj
} -ThrottleLimit 30

#----------------------------------
# return output or export to csv
IF ($ExportToCsv){
	$LatencyCheck | Sort-Object Endpoint | export-Csv $CsvFilepath -Append
}
ELSE {
	$LatencyCheck | Sort-Object RTT | FT
}
