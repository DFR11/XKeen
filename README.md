# Xray-Keenetic

> [!WARNING]
> This material was prepared for scientific and technical purposes. The XKeen utility is designed to manage the Keenetic router firewall, which protects your home network. The developer is not responsible for any other use of it. Before using XKeen, please ensure that your actions comply with the laws of your country. Using XKeen for illegal purposes is strictly prohibited

> [!NOTE]
> Installation of XKeen is guaranteed only on external USB drives, while installation on the internal memory of the router is possible, but requires the user’s knowledge and experience. If you have difficulties installing on internal memory, do not report it as a bug in the installer. The problem is not with XKeen

## Version 1.1.3.8

Comparison of the fork with the original XKeen

Changes:
- translate ru language to  en
Added:
- Mihomo kernel support
- Ability to change the proxy kernel (Xray/Mihomo) with the `-xray` and `-mihomo` parameters
- Possibility of [OffLine installation](https://github.com/jameszeroX/XKeen/blob/main/OffLine_install.md) (option `-io`)
- Ability to install a GeoIP database [zkeenip.dat](https://github.com/jameszeroX/zkeen-ip)
- Update [zkeen.dat](https://github.com/jameszeroX/zkeen-domains) and [zkeenip.dat](https://github.com/jameszeroX/zkeen-ip) on a schedule using XKeen
- If the GitHub API is unavailable, a backup release source for XKeen, Xray and Mihomo is used
- If the GitHub repository is unavailable, XKeen components are downloaded through a proxy
- Protection against accidentally entering a hyphen instead of a colon when specifying a range of proxy ports or exclusion ports
- Поддержка внешнего файла `/opt/etc/xkeen_exclude.lst` c IP-адресами и подсетями для исключения из проксирования ([образец](https://raw.githubusercontent.com/jameszeroX/xkeen/main/xkeen_exclude.lst))
- During installation, you can now choose whether to add XKeen to startup when you turn on the router or not
- If you skip the installation of Xray, its configuration files and geobases are also skipped and not installed
- Mihomo and the Yq yaml file parser are installed and registered in entware as full-fledged ipk packages
- Launch option `-remove` to completely uninstall XKeen (previously you had to uninstall it piece by piece)
- Error 500 (Server Error)!!1500.That’s an error.There was an error. Please try again later.That’s all we know.
- Launch option `-um` to update/install Mihomo kernel (upgrade/downgrade supported)
- Launch options: `-rrm` (update Mihomo registration), `-drm` (delete Mihomo registration)
- Launch option `-dm` to uninstall the Mihomo kernel
- Launch option `-g`, which allows you to reinstall (add/remove) geofiles for Xray
- Launch parameter `-channel`, allowing you to select the XKeen update channel between the Stable and Dev branches
- Ability to backup and restore Mihomo configuration (parameters `-mb`, `-mbr`)
- Ability to control the number of open file descriptors used by the proxy client and restart the process when the limit is reached [more](https://github.com/jameszeroX/XKeen/blob/main/FileDescriptors.md)

Deleted:
- Ability to install GeoSite Antizapret (the database is damaged in the repository)
- Configuration file 02_transport.json (not used by new xray-cores)
- Request to overwrite and overwrite Xray configuration files if they already exist at the time of XKeen installation
- Create Xray backups, since you can now interactively install a previous version of the kernel with the `-ux` option. In this regard, the launch options `-xb` and `-xbr` have been removed
- Логирование процесса установки XKeen в директорию `/opt/var/log/xkeen` (на практике не использовалось)
- XKeen/Xray auto-update scheduler tasks. In this regard, the launch options `-uac`, `-ukc`, `-uxc`, `-dac`, `-dkc` and `-dxc` have been removed
- Launch options: `-x` (replaced by `-ux`), `-rk` (replaced by `-rrk`), `-rx` (replaced by `-rrx`), `-rc` (not relevant)

All launch parameters with their descriptions are available in the help for the `xkeen -h` command

### Installation procedure
```
opkg update && opkg upgrade && opkg install curl tar
curl -OL https://raw.githubusercontent.com/DFR11/XKeen/refs/heads/main/install.sh
chmod +x install.sh
./install.sh
```
Alternative:
```
opkg update && opkg upgrade && opkg install curl tar
curl -OL https://ghfast.top/https://github.com/DFR11/XKeen/releases/download/1.0.0/xkeen.tar.gz
tar -xvzf xkeen.tar.gz -C /opt/sbin > /dev/null && rm xkeen.tar.gz
xkeen -i
```
Установка [OffLine](https://github.com/jameszeroX/XKeen/blob/main/OffLine_install.md)


### Support
The XKeen fork, like the original, is completely free and has no restrictions on use. I hope the improvements to XKeen, many of which I made at your request, turned out to be useful, as well as my consultations in [telegram chat](https://t.me/+8Cvh7oVf6cE0MWRi). It is very important for me to understand that work and time were not wasted. I would be grateful for any of your support:

[CloudTips](https://pay.cloudtips.ru/p/7edb30ec)

[ЮMoney](https://yoomoney.ru/to/41001350776240)

MIR card: `2204 1201 2976 4110`

USDT, сеть TRC20: `TQhy1LbuGe3Bz7EVrDYn67ZFLDjDBa2VNX`

USDT, сеть ERC20: `0x6a5DF3b5c67E1f90dF27Ff3bd2a7691Fad234EE2`


### Sources
Origin <https://github.com/Skrill0/XKeen>

Xray-core <https://github.com/XTLS/Xray-core>

Mihomo <https://github.com/MetaCubeX/mihomo>

FAQ <https://jameszero.net/faq-xkeen.htm>

Telegram <https://t.me/+8Cvh7oVf6cE0MWRi> (discussion, installation instructions, usage tips)
