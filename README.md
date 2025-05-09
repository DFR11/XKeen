Xray-Keenetic

原项目：https://github.com/Skrill0/XKeen

常见问题（FAQ）：https://jameszero.net/faq-xkeen.htm

Telegram 群组：https://t.me/+SZWOjSlvYpdlNmMy（讨论、安装指南、使用建议）
版本 1.1.3.4
相对于原始 XKeen 的变更对比：

更改内容：

    XKeen 安装最新版 xray-core，并根据计划检查更新（此前固定安装的是 1.8.4）

    修复了添加端口到排除项的问题（此前 xkeen -ape 命令需手动 ctrl+c 中断）

    修复了 TProxy 模式与 socks5 的协同工作问题（此前以 Mixed 模式运行，导致失效）

    修复了路由器启动时 XKeen 的自启动（此前可能未启动或错误启动为全局设备，而非绑定策略 – 详见 FAQ 第12条）

    将 GeoSite 和 GeoIP 的更新任务合并，因此废除了以下命令参数：
    -ugs、-ugi、-ugsc、-ugic、-dgsc、-dgic

    正确卸载 xray-core（此前卸载未删除 xray 包）

    帮助信息（xkeen -h）对齐排版，提升文字对比度

    脚本进行了一些视觉与功能优化

    更新了 xray-core 的配置文件

新增功能：

    支持离线安装（参数 -io）

    可安装 GeoIP 数据库 zkeenip.dat

    通过 XKeen 定期更新 zkeen.dat 和 zkeenip.dat

    新增命令参数 -remove 用于完整卸载 XKeen（此前需要逐个组件卸载）

    新增命令参数：

        -ug（更新 geo 数据文件）

        -ugc（管理 geo 文件更新的 Cron 任务）

        -dgc（删除 geo 文件更新的 Cron 任务）

移除内容：

    不再支持安装 GeoSite Antizapret（仓库中的数据库已损坏）

    移除了 transport.json 配置文件（新版 xray-core 不再使用）

安装流程

opkg install curl
curl -OfL https://raw.githubusercontent.com/jameszeroX/XKeen/main/install.sh && chmod +x ./install.sh
./install.sh

或使用替代方式：

opkg install ca-certificates wget-ssl tar
wget "https://cdn.jsdelivr.net/gh/jameszeroX/XKeen@main/xkeen.tar" && tar -xvf xkeen.tar -C /opt/sbin --overwrite > /dev/null && rm xkeen.tar
xkeen -i

离线安装：链接
支持作者（如果你愿意请我喝杯啤酒 🍺）

    USDT（TRC20 网络）：

TB9dLwzNdLB6QeKV6w4FjCACSarePb32Dg

    USDT（TON 网络）：

UQDHmmyz0e1K07Wf7aTVtdmcGzCPfo4Pf7uBi_Id8TDI6Da6
