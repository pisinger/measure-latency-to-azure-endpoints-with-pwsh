# measure-latency-to-azure-endpoints-with-pwsh

As `latency is the new cloud currency` I decided to create a PowerShell script which does make use of `PSPING` to do latency checks. In fact, this script does leverage PSPING for checking latency by doing TCP handshakes to the endpoints specified in `$endpoints` hash table - by default it will trigger PSPING to make 3 TCP connects and will then simply grab the average timings provided by psping.

Sure, you could also leverage .NET classes and doing manual measurement to archive the same but as I personally do use psping actually quite often, I tried to incorporate it somehow without reinventing the wheel.

> Note: PowerShell Core required: <https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows/>

`This might be helpful in case you want to run latency checks automated from internal Windows clients or edge devices, as well checking for regional routing.`

The script will auto-download psping if not yet exists in script folder.
> PSPING: <https://docs.microsoft.com/en-us/sysinternals/downloads/psping/>

**Requirements:**

```diff
+ Direct Connectivity allowing TCP 443 outbound
+ DNS Client Resolution
- Not working when proxy usage is required
```

`You could also replace the pre-defined Azure Endpoints by some other M365 endpoints, or just to any endpoint you are interested in, as well changing the connecting port.`

**EXAMPLES:**

```powershell
.\measure-latency-to-azure-endpoints-via-psping.ps1
.\measure-latency-to-azure-endpoints-via-psping.ps1 -ExportToCsv
.\measure-latency-to-azure-endpoints-via-psping.ps1 -ExportToCsv "c:\temp\results.txt"
```

```txt
Region             Endpoint                                     DnsName           RTT IPAddr
------             --------                                     -------           --- ------
Europe West        speedtestwe.blob.core.windows.net            ams06prdstr14a   0,99 52.239.213.4
UK South           speedtestuks.blob.core.windows.net           ln1prdstr05a     7,96 51.141.129.74
UK West            speedtestukw.blob.core.windows.net           cw1prdstr23a     9,62 20.150.52.4
France Central     speedtestfrc.blob.core.windows.net           par21prdstr01a  10,04 52.239.134.100
Germany North      speedtestden.blob.core.windows.net           ber20prdstr02a  10,51 20.38.115.4
Europe North       speedtestne.blob.core.windows.net            db3prdstr11a    16,81 52.239.137.4
Switzerland West   speedtestchw.blob.core.windows.net           gva20prdstr02a  20,66 52.239.250.4
Switzerland North  speedtestchn.blob.core.windows.net           zrh20prdstr02a  22,16 52.239.251.68
US East            speedtesteus.blob.core.windows.net           bl6prdstr05a    81,25 52.240.48.36
Canada Central     speedtestcac.blob.core.windows.net           yt1prdstr03a    95,44 40.85.235.62
US North Central   speedtestnsus.blob.core.windows.net          chi21prdstr01a  96,28 52.239.186.36
Canada East        speedtestcae.blob.core.windows.net           yq1prdstr10a   102,55 20.150.1.4
US Central         speedtestcus.blob.core.windows.net           dm5prdstr12a   108,47 52.239.151.138
US South Central   speedtestscus.blob.core.windows.net          sn4prdstr09a   114,75 52.239.158.138
US West Central    speedtestwestcentralus.blob.core.windows.net cy4prdstr01a   117,64 13.78.152.64
UAE North          speedtestuaen.blob.core.windows.net          dxb20prdstr02a 121,87 52.239.233.228
India Central      speedtestcentralindia.blob.core.windows.net  pn1prdstr03a   126,03 104.211.109.52
India West         speedtestwestindia.blob.core.windows.net     bm1prdstr01a   127,77 104.211.168.16
US West            speedtestwus.blob.core.windows.net           sjc20prdstr12a 140,57 52.239.228.228
India East         speedtesteastindia.blob.core.windows.net     ma1prdstr07a   144,52 52.239.135.164
Asia Southeast     speedtestsea.blob.core.windows.net           sg2prdstr02a   157,84 52.163.176.16
South Africa North speedtestsan.blob.core.windows.net           jnb21prdstr01a 183,25 52.239.232.36
Brazil East        speedtestnea.blob.core.windows.net           cq2prdstr01a   186,03 191.232.216.52
Brazil South       speedtestbs.blob.core.windows.net            cq2prdstr03a   187,05 191.233.128.42
Asia East          speedtestea.blob.core.windows.net            hk2prdstr06a   189,71 52.175.112.16
Korea South        speedtestkoreasouth.blob.core.windows.net    ps1prdstr01a   212,54 52.231.168.142
Japan West         speedtestjpw.blob.core.windows.net           os1prdstr02a   220,15 52.239.146.10
Korea Central      speedtestkoreacentral.blob.core.windows.net  se1prdstr01a   220,41 52.231.80.94
Japan East         speedtestjpe.blob.core.windows.net           tyo22prdstr02a 222,07 52.239.145.36
AUS Southeast      speedtestozse.blob.core.windows.net          mel20prdstr02a 242,57 52.239.132.164
AUS East           speedtestoze.blob.core.windows.net           sy3prdstr07a   243,37 52.239.130.74
```
