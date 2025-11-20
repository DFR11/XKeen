## Version 1.1.3.9 Beta

> [!WARNING]
> This is a version from the development channel. It is regularly updated to contain the latest features, functionality and fixes, but may contain undetected bugs. If you encounter a problem, be sure to update with the command `xkeen -uk`, perhaps the error is already known and fixed. If the problem persists, run `xkeen -diag` and show the diagnostic report in the telegram chat https://t.me/+8Cvh7oVf6cE0MWRi, describing the problem in detail

### Changes
- When updating Xray and Mihomo, the version of the binary already installed in the router is now displayed
- Fixed adding a port range to proxy exceptions
- The technical restriction that allowed the use of no more than 15 proxy ports and ports excluded from proxying has been removed
- More correct parsing of the xray DNS server configuration file
- Fixed XKeen autorun crash that occurred in some cases
- The S24xray startup script has been renamed to S99xkeen, the S99xkeenstart helper script has been removed
- Добавлена поддержка внешних файлов `ip_exclude.lst`, `port_proxying.lst` и `port_exclude.lst` в директории /opt/etc/xkeen/ для указания IP и портов (проксирования/исключения из проксирования)
- Added compatibility with KeeneticOS 5.0 firmware


### How to update from version 1.1.3.8
Switch to the development channel and update:
```
xkeen -channel
xkeen -uk
```
In the development channel, the command `xkeen -uk` downloads and installs the current beta of XKeen every time it is launched

### Installation procedure
```
opkg update && opkg upgrade && opkg install curl tar
curl -OL https://raw.githubusercontent.com/jameszeroX/xkeen/main/test/xkeen.tar.gz
tar -xvzf xkeen.tar.gz -C /opt/sbin > /dev/null && rm xkeen.tar.gz
xkeen -i
```
