## Version 1.1.3.10 Beta

> [!NOTE]
> Это версия из канала разработки. Она регулярно дорабатывается, содержит новейшие функции, возможности и исправления, но может иметь не выявленные ошибки. Если столкнулись с проблемой - обязательно обновитесь командой `xkeen -uk`, возможно ошибка уже известна и исправлена. Если же проблема сохранилась, выполните `xkeen -diag` и покажите диагностический отчёт в телеграм-чате https://t.me/+8Cvh7oVf6cE0MWRi, подробно описав возникшую проблему

### Changes
- Implemented work with custom policies <sup>1</sup>
- Improved module for working with DNS <sup>2</sup>
- Port 443 in the router interface now needs to be released only for TProxy mode; users of Mixed mode do not have to do this
- The version of the yq utility is fixed for stability
- Proxy and exclusion ports have been completely moved to `port_proxying.lst` and `port_exclude.lst`. The options `-ap`, `-dp`, `-cp`, `-ape`, `-dpe`, `-cpe` currently only work with these files. The `port_donor` and `port_exclude` variables are no longer used.
- Added `-toff` option to disable upload timeout when GitHub slows down. Usage example: `xkeen -ux -toff`

<sup>1</sup> В роутинге, используя параметр `source`, вы можете определить разные правила маршрутизации для разных устройств, а пользовательские политики дают возможность задать для них разные порты проксирования, например, для торрент-клиента можно сделать политику с `80,443` портами проксирования, для телефонов политику с портами `80,443,596:599,1400,3478,5222`, а для игровых устройств с более широким набором портов. Для работы с пользовательскими политиками, они должы быть определены в конфигурационном файле `/opt/etc/xkeen/xkeen.json`, а также созданы в интерфейсе роутера с теми же именами. Пользовательские политики подключаются только если в интерфейсе роутера создана дефолтная политика `xkeen`, иначе пользовательские политики игнорируются и проксирование запускается для всех клиентов роутера. В пользовательских политиках, в отличие от политики `xkeen`, не проверяется наличие обязательных портов проксирования `80,443`, и вы можете формировать произвольный их список. Пример конфигурационного файла (допустимы любые имена пользовательских политик):
```
{
  "xkeen": {
    "policy": [
      {
        "name": "xkeen0",
        "port": ""
      },
      {
        "name": "xkeen1",
        "port": "80,443,596:599,1400,3478,5222"
      },
      {
        "name": "xkeen2",
        "port": "!7777,8888:9999"
      }
    ]
  }
}
```

- Policy `xkeen0` - proxying on all ports
- Policy `xkeen1` - proxying on the listed ports
- Policy `xkeen2` - proxying on all ports except those listed

<sup>2</sup> При включенном перехвате и проксировании DNS, корректная работа устройств вне политик XKeen возможна только когда они находятся не в "Политике по умолчанию", а в кастомной политике с произвольным именем и в роутере не игнорируется DNS провайдера либо добавлен любой внешний не шифрованный DNS (даже при использовании AdGuardHome и отключении прошивочного резолвера командой `opkg dns-override`)

---

### How to upgrade from a previous version of the XKeen fork
Switch to the development channel
```
xkeen -channel
```
and update with local reinstallation:
```
xkeen -stop
xkeen -uk
xkeen -k 	# тут выбрать пункт 0
xkeen -start
```
Subsequent runs of the `xkeen -uk` command in the development channel download and update the XKeen beta to the current version

### Installation procedure from scratch
```
opkg update && opkg upgrade && opkg install curl tar && cd /tmp
curl -OL https://raw.githubusercontent.com/jameszeroX/xkeen/main/test/xkeen.tar.gz
tar -xvzf xkeen.tar.gz -C /opt/sbin > /dev/null && rm xkeen.tar.gz
xkeen -i
```
