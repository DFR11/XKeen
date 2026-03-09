# XKeen 1.1.3.9

> **XKeen** is a utility for selective routing of network traffic through proxy engines **Xray** and **Mihomo** on **Keenetic**/**Netcraze** routers.
> Allows you to transparently route TCP/UDP traffic to only selected clients without affecting the rest of the network.

---

## Key Features

- Selective routing for clients in Internet access policy
- Maintaining direct Internet access for other clients
- Routing without policy for all router clients
- Поддержка режимов **TProxy**, **Mixed**, **Redirect**, **Other** (socks5/http)
- Transparent proxying **TCP** and **UDP**
- Support for **Xray** and **Mihomo** proxy kernels
- Compatible with **KeeneticOS 5+**
- Управление через shell и [веб-панели](https://github.com/jameszeroX/XKeen?tab=readme-ov-file#дополнения) сторонних разработчиков

XKeen works entirely on the router side, does not change client settings and does not require installation of additional programs on them.

---

## Warnings

> [!WARNING]
> This material was prepared for scientific and technical purposes. XKeen is designed to manage the Keenetic router firewall, which protects your home network. The developer is not responsible for any other use of the utility. Before use, make sure that your actions comply with the laws of your country.

> [!CAUTION]
> In some cases, IPv6 creates problems with proxying. In KeeneticOS, IPv6 cannot be completely disabled using standard means. XKeen implements an alternative mechanism for disabling it, which completely removes IPv6 traffic on the router. This is an **experimental feature** and may cause some Keenetic services to not work correctly. Use it only when necessary.

> [!NOTE]
> Installation of XKeen is guaranteed on external USB drives. Installation into the internal memory of the router is possible, but requires user experience. Problems related to installation to internal memory are not considered XKeen errors.

---

This repository is a fork of the original XKeen with fixes, expanded functionality and support for current versions of KeeneticOS.

## Key changes of the fork

### Corrected

- autostart XKeen
- restrictions on the number of used ports have been removed

### Added

- support **KeeneticOS 5+**
- IPv6 management
- **Mihomo** kernel support
- fast switching Xray / Mihomo
- контроль [файловых дескрипторов](https://github.com/jameszeroX/XKeen/blob/main/configuration.md#контроль-файловых-дескрипторов)
- [внешние списки](https://github.com/jameszeroX/XKeen/blob/main/configuration.md#внешние-списки-портов-и-ip) IP и портов
- [OffLine](https://github.com/jameszeroX/XKeen/blob/main/configuration.md#offline-установка)‑установка
- [Self-Hosted](https://github.com/jameszeroX/XKeen/blob/main/configuration.md#self-hosted-прокси-для-загрузки)-прокси для загрузки компонентов

### Deleted

- out-of-date and damaged geobases
- unused configuration files
- outdated launch options and scheduler tasks

---

### Подробное [описание изменений](https://github.com/jameszeroX/XKeen/blob/main/forkinfo.md)

---

A list of XKeen launch options is available in the help:
```bash
xkeen -h
```

---

## Installation procedure

Requires **Keenetic**/**Netcraze** router with Entware pre-installed

Option 1:

```bash
opkg update && opkg upgrade && opkg install curl tar && cd /tmp
url="https://raw.githubusercontent.com/jameszeroX/XKeen/main/install.sh"
curl -OL "$url" && chmod +x install.sh
./install.sh
```

Option 2:

```bash
opkg update && opkg upgrade && opkg install curl tar && cd /tmp
url="https://github.com/jameszeroX/XKeen/releases/latest/download/xkeen.tar.gz"
urlfix="https://raw.githubusercontent.com/jameszeroX/xkeen/main/01_info_variable.sh"
curl -OL "$url" && tar -xvzf xkeen.tar.gz -C /opt/sbin > /dev/null && rm xkeen.tar.gz
curl -Lo /opt/sbin/_xkeen/01_info/01_info_variable.sh "$urlfix"
xkeen -i
```

---

## Project support

Форк XKeen, как и оригинал, совершено бесплатен и не имеет каких либо ограничений по использованию. Надеюсь, доработки XKeen, многие из которых я сделал по Вашим просьбам, оказались полезны, так же, как и мои сообщения в [телеграм-чате](https://t.me/+8Cvh7oVf6cE0MWRi). Для меня очень важно понимать, что труд и время потрачены не зря. Буду благодарен за любую Вашу поддержку на развитие проекта:

- [CloudTips](https://pay.cloudtips.ru/p/7edb30ec)
- [ЮMoney](https://yoomoney.ru/to/41001350776240)
- MIR card: `2204 1201 2976 4110`
- USDT, сеть TRC20: `TQhy1LbuGe3Bz7EVrDYn67ZFLDjDBa2VNX`
- USDT, сеть ERC20: `0x6a5DF3b5c67E1f90dF27Ff3bd2a7691Fad234EE2`

<sup>Уточните актуальность крипто-адресов перед переводом</sup>

---

## Add-ons

- XKeen UI — https://github.com/zxc-rv/XKeen-UI
- XKeen UI — https://github.com/umarcheh001/Xkeen-UI
- Генератор Outbound — https://zxc-rv.github.io/XKeen-UI/Outbound_Generator/
- SubKeen — https://github.com/V2as/SubKeen
- Mihomo Studio — https://github.com/l-ptrol/mihomo_studio
- Конвертер JSON-подписок — https://sngvy.github.io/json-sub-to-outbounds
- Mihomo HWID Subscription Installer — https://github.com/dorian6996/Mihomo-HWID-Subscription

---

## Sources and links

- Origin XKeen — https://github.com/Skrill0/XKeen
- Xray-core — https://github.com/XTLS/Xray-core
- Mihomo — https://github.com/MetaCubeX/mihomo
- Yq — https://github.com/mikefarah/yq
- FAQ — https://jameszero.net/faq-xkeen.htm
- Telegram‑чат — https://t.me/+8Cvh7oVf6cE0MWRi
