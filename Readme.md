# measure-latency-to-azure-endpoints-with-pwsh

As `latency is the new cloud currency` I decided to create a PowerShell script which does make use of `PSPING` to do latency checks. In addition, this repo does now also offer a script doing the same in `.NET`. So with that you could do your latency checks natively in PowerShell, which might be more helpful when running it from Linux-based edge devices.

> Note: PowerShell Core required: <br/>
> * <https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows/> <br/>
> * <https://aka.ms/GetPowershell/>

`This might be helpful in case you want to run latency checks automated from internal clients or edge devices, as well checking for regional routing.`

> You may also want to have a look to `AzureSpeedTest2` web utility where you can check for latency directly from within the browser: <br/>
> * <https://github.com/richorama/AzureSpeedTest2/> <br/>
> * <https://richorama.github.io/AzureSpeedTest2/>

---

**measure-latency-to-azure-endpoints-via-dotnet.ps1:** With that script you could do your latency checks natively in PowerShell instead of leveraging psping, which might be more helpful when running it from Linux-based edge devices. It again connects to the endpoints specified in `$endpoints` hash table. You can also specify different ports to be used by just adding the desired port as `:5061` or `:80`.

It does now also provide support for proxy use - so when you have the requirement to use a proxy to connect to the internet, then try to run the script together with the `$Proxy` switch.

By default it will make `4` consequent TCP connects to grab average timings (at least 3 connect attempts required) - you can adjust this by changing `$iterations` param. Beside of AVG it will give you also the MIN and MAX latency value - for the average the lowest and highest value will be excluded.

To save your results when running the script in an automated way, simply run with the `$ExportToCsv` switch.

---

**Requirements:**

```diff
+ PowerShell Core

+ Direct Connectivity allowing TCP 443 outbound (or the custom port you defined)
+ DNS Client Resolution
- Proxy Use not tested in depth
```

`You could also replace the pre-defined Azure Endpoints by some other M365 endpoints, or just to any endpoint you are interested in, as well changing the connecting port.`

**EXAMPLES:**

```powershell
.\measure-latency-to-azure-endpoints-via-dotnet.ps1 | ft
.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -Iterations 10
.\measure-latency-to-azure-endpoints-via-dotnet.ps1 -Proxy -Iterations 5
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

To run it against other endpoints simply adjust the `$endpoints` hash table as shown below. You can also specify a different port to be used by just adding the desired port as `:5061` or `:80`.

```powershell
$Endpoints = @{
    "Exchange"      = "outlook.office.com"
    "worldaz"       = "worldaz.tr.teams.microsoft.com"
    "euaz"          = "euaz.tr.teams.microsoft.com"
    "usaz"          = "usaz.tr.teams.microsoft.com"
    "PSTN Hub 1"    = "sip.pstnhub.microsoft.com:5061"
    "PSTN Hub 2"    = "sip2.pstnhub.microsoft.com:5061"
    "PSTN Hub 3"    = "sip3.pstnhub.microsoft.com:5061"
}
```

```txt
Region     Endpoint                       Port DnsName1           DnsName2      RTTMin RTTAvg RTTMax RTTs                 IPAddr
------     --------                       ---- --------           --------      ------ ------ ------ ----                 ------
PSTN Hub 1 sip.pstnhub.microsoft.com      5061 sip-du-a-euwe      westeurope         2      2     10 {2, 10, 3, 2}        52.114.75.24
Exchange   outlook.office.com             443  AMS-efz            ms-acdc            2      2      2 {2, 2, 2, 2}         52.97.200.178
worldaz    worldaz.tr.teams.microsoft.com 443  a-tr-teasc-ukwe-05 ukwest            23     42     81 {23, 40, 81, 45}     52.114.94.220
euaz       euaz.tr.teams.microsoft.com    443  a-tr-teasc-ukwe-01 ukwest            26     33     84 {26, 29, 84, 37}     52.113.202.62
usaz       usaz.tr.teams.microsoft.com    443  a-tr-teasc-usea-04 eastus            99    144    186 {124, 164, 186, 99}  52.114.141.6
PSTN Hub 2 sip2.pstnhub.microsoft.com     5061 sip-du-a-uswe2     westus2          139    146    150 {150, 144, 139, 149} 52.114.148.0
PSTN Hub 3 sip3.pstnhub.microsoft.com     5061 sip-du-a-asse      southeastasia    158    168    175 {162, 173, 175, 158} 52.114.14.70
```

When you have proxy requirement, then you can try to run the script with the `Proxy` switch instead.

```txt
Region             Endpoint                                                     Success RTTMin RTTAvg RTTMax RTTs
------             --------                                                     ------- ------ ------ ------ ----
UK South           https://speedtestuks.blob.core.windows.net/cb.json              True 12     12     13     {12, 13, 13, 12}
France Central     https://speedtestfrc.blob.core.windows.net/cb.json              True 16     22     36     {23, 36, 21, 16}
UK West            https://speedtestukw.blob.core.windows.net/cb.json              True 21     23     25     {23, 25, 21, 23}
Europe North       https://speedtestne.blob.core.windows.net/cb.json               True 23     28     34     {23, 25, 34, 32}
US East            https://speedtesteus.blob.core.windows.net/cb.json              True 86     86     97     {86, 97, 87, 86}
Canada Central     https://speedtestcac.blob.core.windows.net/cb.json              True 98     98     99     {98, 98, 99, 98}
US North Central   https://speedtestnsus.blob.core.windows.net/cb.json             True 108    108    109    {108, 109, 108, 108}
Canada East        https://speedtestcae.blob.core.windows.net/cb.json              True 109    114    171    {109, 114, 171, 114}
US South Central   https://speedtestscus.blob.core.windows.net/cb.json             True 119    124    143    {128, 120, 143, 119}
US West Central    https://speedtestwestcentralus.blob.core.windows.net/cb.json    True 121    122    124    {121, 124, 123, 122}
UAE North          https://speedtestuaen.blob.core.windows.net/cb.json             True 125    126    134    {134, 127, 125, 126}
Korea South        https://speedtestkoreasouth.blob.core.windows.net/cb.json       True 219    220    221    {221, 219, 219, 220}
AUS Southeast      https://speedtestozse.blob.core.windows.net/cb.json             True 244    246    248    {244, 248, 245, 246}
AUS East           https://speedtestoze.blob.core.windows.net/cb.json              True 253    253    254    {253, 253, 253, 254}
```
