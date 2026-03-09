## Comparison of the fork with the original XKeen

Changes:
- Fixed adding ports to exceptions (previously the `xkeen -ape` command had to be interrupted by ctrl+c)
- Fixed the joint operation of TProxy and socks5 modes (previously Xkeen was launched in Mixed mode, which led to transparent proxying not working)
- Исправлен автозапуск XKeen при старте роутера (ранее XKeen в некоторых случаях не запускался или запускался для всего устройства, а не только для своей политики - [FAQ п.12](https://jameszero.net/faq-xkeen.htm#12))
- The technical restriction that allowed the use of no more than 15 proxy ports and ports excluded from proxying has been removed
- The logic for downloading XKeen, Xray, Mihomo and GeoFile from the Internet has been reworked, reducing the likelihood of their damage
- The logic for applying iptables and ip6tables rules has been reworked (previously XKeen applied all rules, even when the IPv6 component was not installed)
- The logic for adding and removing proxy ports and excluded ports has been reworked
- When updating geofiles, adding/removing proxy ports or exclusion ports, as well as performing other settings that require restarting XKeen, the proxy client is now restarted if it was previously running
- When running `xkeen -d` without a numeric parameter, information about the current autorun delay is now displayed
- When starting or restarting XKeen, information about the operating mode is now displayed - TProxy, Mixed, Redirect, Other
- Не актуальные GeoSite и GeoIP antifilter-community заменены на базы [Re:filter](https://github.com/1andrevich/Re-filter-lists)
- The scheduler tasks for updating GeoSite and GeoIP have been combined. In this regard, the launch parameters `-ugs`, `-ugi`, `-ugsc`, `-ugic`, `-dgsc`, `-dgic` have been removed
- The `-ux` startup option for Xray kernel upgrade now supports upgrading/downgrading
- Correct uninstallation of xray-core (previously the xray package was not removed during uninstallation)
- Help (`xkeen -h`) tab-aligned and increased text contrast
- S24xray launch script renamed to S99xkeen
- Refactoring script code
- Updating xray-core configuration files

Added:
- Compatible with KeeneticOS 5+ firmware
- Ability to disable/enable IPv6 protocol in KeeneticOS (launch parameter `-ipv6`)
- Mihomo kernel support
- Ability to change the proxy kernel (Xray/Mihomo) with the `-xray` and `-mihomo` parameters
- When updating Xray and Mihomo, the version of the binary already installed in the router is now displayed
- Added the ability to disable/enable interception of DNS requests when the proxy client is configured accordingly (launch parameter `-dns`)
- Поддержка внешних файлов `ip_exclude.lst`, `port_proxying.lst` и `port_exclude.lst` в директории `/opt/etc/xkeen/` для указания IP и портов (проксирования/исключения из проксирования)
- Возможность загружать компоненты XKeen через [Self-Hosted прокси](https://github.com/jameszeroX/XKeen/blob/main/configuration.md#self-hosted-прокси-для-загрузки-компонентов) при недоступности GitHub (переменные `gh_proxy(1|2)` в файле `01_info_variable.sh`)
- Option to disable XKeen backup when updating (`backup` variable in `S99xkeen` file)
- Возможность [OffLine установки](https://github.com/jameszeroX/XKeen/blob/main/configuration.md#offline-установка) (параметр `-io`)
- Возможность установки GeoIP базы [zkeenip.dat](https://github.com/jameszeroX/zkeen-ip)
- Обновление [zkeen.dat](https://github.com/jameszeroX/zkeen-domains) и [zkeenip.dat](https://github.com/jameszeroX/zkeen-ip) по расписанию средствами XKeen
- If the GitHub API is unavailable, a backup release source for XKeen, Xray and Mihomo is used
- During installation, you can now choose whether to add XKeen to startup when you turn on the router or not
- If you skip the installation of Xray, its configuration files and geobases are also skipped and not installed
- Mihomo and the Yq yaml file parser are installed and registered in entware as full-fledged ipk packages
- Launch option `-remove` to completely uninstall XKeen (previously you had to uninstall it piece by piece)
- Launch options `-ug` (update geofiles), `-ugc` (manage a Cron job that updates geofiles), `-dgc` (delete a Cron job that updates geofiles)
- Launch option `-um` to update/install Mihomo kernel (upgrade/downgrade supported)
- Launch options: `-rrm` (update Mihomo registration), `-drm` (delete Mihomo registration)
- Launch option `-dm` to uninstall the Mihomo kernel
- Launch option `-g`, which allows you to reinstall (add/remove) geofiles for Xray
- Launch parameter `-channel`, allowing you to select the XKeen update channel between the Stable and Dev branches
- Ability to backup and restore Mihomo configuration (parameters `-mb`, `-mbr`)
- Возможность контролировать число открытых файловых дескрипторов, используемых прокси-клиентом и перезапускать процесс при исчерпании лимита  [подробнее](https://github.com/jameszeroX/XKeen/blob/main/configuration.md#контроль-файловых-дескрипторов)

Deleted:
- Поддержка внешнего файла `/opt/etc/xkeen_exclude.lst` c IP-адресами и подсетями для исключения из проксирования
- Ability to install GeoSite Antizapret (the database is damaged in the repository)
- Configuration file `02_transport.json` (not used by new xray-core kernels)
- Request to overwrite and overwrite Xray configuration files if they already exist at the time of XKeen installation
- Create Xray backups, since you can now interactively install a previous version of the kernel with the `-ux` option. In this regard, the launch options `-xb` and `-xbr` have been removed
- Логирование процесса установки XKeen в директорию `/opt/var/log/xkeen` (на практике не использовалось)
- XKeen/Xray auto-update scheduler tasks. In this regard, the launch options `-uac`, `-ukc`, `-uxc`, `-dac`, `-dkc` and `-dxc` have been removed
- Launch options: `-x` (replaced by `-ux`), `-rk` (replaced by `-rrk`), `-rx` (replaced by `-rrx`), `-rc` (not relevant)
