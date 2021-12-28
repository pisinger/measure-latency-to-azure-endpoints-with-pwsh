# measure-latency-to-azure-endpoints-with-pwsh

As `latency is the new cloud currency` I decided to create a PowerShell script which does make use of `PSPING` to do latency checks. In addition, this repo does now also offer a script doing the same in `.NET`. So with that you could do your latency checks natively in PowerShell, which might be more helpful when running it from Linux-based edge devices.

`This might be helpful in case you want to run latency checks automated from internal clients or edge devices, as well checking for regional routing.`

---

**measure-latency-to-azure-endpoints-via-psping.ps1:** This script does leverage PSPING for checking latency by doing TCP handshakes to the endpoints specified in `$endpoints` hash table - by default it will trigger PSPING to make 3 TCP connects and will then simply grab the average timings provided by psping.

The psping-based script will also auto-download psping itself if not yet exists in script folder.
> PSPING: <https://docs.microsoft.com/en-us/sysinternals/downloads/psping/>

---

**measure-latency-to-azure-endpoints-via-dotnet.ps1:** With that script you could do your latency checks natively in PowerShell, which might be more helpful when running it from Linux-based edge devices. It again connects to the endpoints specified in `$endpoints` hash table. By default it will make 4 consequent TCP connects to grab average timings (at least 3 connect attempts required) - you can adjust this by changing "iterations" param. Beside of AVG it will give you also the MIN and MAX latency value - for the average the lowest and highest value will be excluded.

---

> Note: PowerShell Core required: <https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows/>

**Requirements:**

```diff
+ PowerShell Core

+ Direct Connectivity allowing TCP 443 outbound
+ DNS Client Resolution
- Not working when proxy usage is required
```

`You could also replace the pre-defined Azure Endpoints by some other M365 endpoints, or just to any endpoint you are interested in, as well changing the connecting port.`

**EXAMPLES:**

```powershell
.\measure-latency-to-azure-endpoints-via-dotnet.ps1
.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -Iterations 10
.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -ExportToCsv
.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -ExportToCsv -CsvFilepath "c:\temp\results.txt"
```

```txt
Region             Endpoint                                     DnsName1 DnsName2       RTTMin RTTAvg RTTMax RTTs                 IPAddr
------             --------                                     -------- --------       ------ ------ ------ ----                 ------
Europe West        speedtestwe.blob.core.windows.net            blob     ams06prdstr14a      1      2      3 {2, 1, 3, 1}         52.239.213.4
UK South           speedtestuks.blob.core.windows.net           blob     ln1prdstr05a        8      8     10 {8, 10, 8, 9}        51.141.129.74
France Central     speedtestfrc.blob.core.windows.net           blob     par21prdstr01a     10     11     13 {13, 12, 10, 10}     52.239.134.100
UK West            speedtestukw.blob.core.windows.net           blob     cw1prdstr23a       12     18     57 {14, 57, 12, 23}     20.150.52.4
Germany North      speedtestden.blob.core.windows.net           blob     ber20prdstr02a     13     26     37 {13, 37, 29, 24}     20.38.115.4
Europe North       speedtestne.blob.core.windows.net            blob     db3prdstr11a       16     17     18 {17, 18, 17, 16}     52.239.137.4
Switzerland West   speedtestchw.blob.core.windows.net           blob     gva20prdstr02a     21     24     62 {62, 21, 25, 22}     52.239.250.4
Switzerland North  speedtestchn.blob.core.windows.net           blob     zrh20prdstr02a     21     23     24 {23, 21, 24, 23}     52.239.251.68
US East            speedtesteus.blob.core.windows.net           blob     bl6prdstr05a       81     89    105 {97, 81, 105, 81}    52.240.48.36
Canada Central     speedtestcac.blob.core.windows.net           blob     yto22prdstr04a     96     97    112 {96, 96, 98, 112}    20.150.100.65
US North Central   speedtestnsus.blob.core.windows.net          blob     chi21prdstr01a     99    101    102 {99, 101, 102, 101}  52.239.186.36
US Central         speedtestcus.blob.core.windows.net           blob     dm5prdstr12a      104    108    137 {137, 107, 108, 104} 52.239.151.138
Canada East        speedtestcae.blob.core.windows.net           blob     yq1prdstr10a      105    116    142 {125, 142, 106, 105} 20.150.1.4
US South Central   speedtestscus.blob.core.windows.net          blob     sn4prdstr09a      113    115    116 {115, 113, 115, 116} 52.239.158.138
US West Central    speedtestwestcentralus.blob.core.windows.net blob     cy4prdstr01a      117    121    123 {123, 120, 122, 117} 13.78.152.64
UAE North          speedtestuaen.blob.core.windows.net          blob     dxb20prdstr02a    123    123    145 {123, 123, 145, 123} 52.239.233.228
India West         speedtestwestindia.blob.core.windows.net     blob     bm1prdstr01a      124    132    155 {124, 141, 155, 124} 104.211.168.16
India Central      speedtestcentralindia.blob.core.windows.net  blob     pn1prdstr03a      126    132    153 {127, 126, 138, 153} 104.211.109.52
India East         speedtesteastindia.blob.core.windows.net     blob     ma1prdstr07a      140    143    147 {142, 140, 147, 144} 52.239.135.164
US West            speedtestwus.blob.core.windows.net           blob     sjc20prdstr12a    141    143    165 {141, 143, 143, 165} 52.239.228.228
Asia Southeast     speedtestsea.blob.core.windows.net           blob     sg2prdstr02a      157    159    174 {160, 174, 157, 158} 52.163.176.16
South Africa North speedtestsan.blob.core.windows.net           blob     jnb21prdstr01a    179    184    205 {179, 205, 184, 183} 52.239.232.36
Asia East          speedtestea.blob.core.windows.net            blob     hk2prdstr06a      189    189    191 {189, 189, 189, 191} 52.175.112.16
Brazil East        speedtestnea.blob.core.windows.net           blob     cq2prdstr01a      197    198    200 {200, 197, 198, 197} 191.232.216.52
Brazil South       speedtestbs.blob.core.windows.net            blob     cq2prdstr03a      198    200    209 {199, 209, 200, 198} 191.233.128.42
Korea South        speedtestkoreasouth.blob.core.windows.net    blob     ps1prdstr01a      217    218    219 {219, 217, 218, 217} 52.231.168.142
Korea Central      speedtestkoreacentral.blob.core.windows.net  blob     se1prdstr01a      222    224    242 {242, 222, 224, 223} 52.231.80.94
Japan East         speedtestjpe.blob.core.windows.net           blob     tyo22prdstr02a    224    224    258 {258, 224, 224, 225} 52.239.145.36
Japan West         speedtestjpw.blob.core.windows.net           blob     os1prdstr02a      234    236    272 {272, 238, 235, 234} 52.239.146.10
AUS Southeast      speedtestozse.blob.core.windows.net          blob     mel20prdstr02a    240    242    243 {243, 243, 242, 240} 52.239.132.164
AUS East           speedtestoze.blob.core.windows.net           blob     sy3prdstr07a      244    246    247 {244, 246, 247, 246} 52.239.130.74
```

To run it against other endpoints simply adjust the `$endpoints` hash table as shown below.

```powershell
$Endpoints = @{
    "Exchange"  = "outlook.office.com"
    "worldaz"   = "worldaz.tr.teams.microsoft.com"
    "euaz"      = "euaz.tr.teams.microsoft.com"
    "usaz"      = "usaz.tr.teams.microsoft.com"
}
```

```txt
Region   Endpoint                       DnsName1            DnsName2   RTTMin RTTAvg RTTMax RTTs                IPAddr
------   --------                       --------            --------   ------ ------ ------ ----                ------
Exchange outlook.office.com             AMS-efz             ms-acdc         2      6   3004 {2, 2, 3004, 11}    52.97.137.66
worldaz  worldaz.tr.teams.microsoft.com a-tr-teasc-euwe-02  westeurope     12     18     36 {12, 16, 36, 19}    52.114.255.255
euaz     euaz.tr.teams.microsoft.com    a-tr-teasc-ukso-04  uksouth        14     22     24 {23, 24, 22, 14}    52.114.252.9
usaz     usaz.tr.teams.microsoft.com    a-tr-teasc-usea2-02 eastus2        99    106    112 {99, 104, 112, 109} 52.115.63.12
```

```powershell
.\measure-latency-to-azure-endpoints-via-psping.ps1
.\measure-latency-to-azure-endpoints-via-psping.ps1 -ExportToCsv
.\measure-latency-to-azure-endpoints-via-psping.ps1 -ExportToCsv -CsvFilepath "c:\temp\results.txt"
```

---

**EXAMPLES - psping version:**

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
