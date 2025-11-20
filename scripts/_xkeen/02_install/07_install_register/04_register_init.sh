#!/bin/sh

# Service Information: Start/Stop XKeen
# Version: 2.28

# Environment
PATH="/opt/bin:/opt/sbin:/sbin:/bin:/usr/sbin:/usr/bin"

# Colors
green="\033[32m"
red="\033[31m"
yellow="\033[33m"
reset="\033[0m"

# Names
name_client="xray"
name_app="XKeen"
name_policy="xkeen"
name_profile="xkeen"
name_chain="xkeen"
name_prerouting_chain="$name_chain"
name_output_chain="${name_chain}_mask"

# Directories
directory_os_modules="/lib/modules/$(uname -r)"
directory_user_modules="/opt/lib/modules"
directory_configs_app="/opt/etc/$name_client"
directory_xray_config="$directory_configs_app/configs"
directory_xray_asset="$directory_configs_app/dat"
directory_logs="/opt/var/log"

# Files
file_netfilter_hook="/opt/etc/ndm/netfilter.d/proxy.sh"
log_access="$directory_logs/$name_client/access.log"
log_error="$directory_logs/$name_client/error.log"
mihomo_config="$directory_configs_app/config.yaml"
file_port_proxying="/opt/etc/xkeen/port_proxying.lst"
file_port_exclude="/opt/etc/xkeen/port_exclude.lst"
file_ip_exclude="/opt/etc/xkeen/ip_exclude.lst"

# URL
url_server="localhost:79"
url_policy="rci/show/ip/policy"
url_keenetic_port="rci/ip/http/ssl"
url_https_port="rci/ip/static"

# iptables rule settings
table_id="111"
table_mark="0x111"
table_redirect="nat"
table_tproxy="mangle"

ipv4_proxy="127.0.0.1"
ipv4_exclude="0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 255.255.255.255"
ipv6_proxy="::1"
ipv6_exclude="::/128 ::1/128 64:ff9b::/96 2001::/32 2002::/16 fd00::/8 ff00::/8 fe80::/10"

port_donor=""
port_exclude=""
port_dns="53"

# Launch Settings
start_attempts=10
start_auto="on"
start_delay=3

# File descriptor control
check_fd="off"
arm64_fd=40000
other_fd=10000
delay_fd=60

# Logging Features
log_info_router() {
    logger -p notice -t "$name_app" "$1"
}

log_warning_router() {
    logger -p warning -t "$name_app" "$1"
}

log_error_router() {
    logger -p error -t "$name_app" "$1"
}

log_error_terminal() {
    echo
    echo -e "${red}Error${reset}: $1" >&2
    exit 1
}

log_warning_terminal() {
    echo
    echo -e "${yellow}Warning${reset}: $1" >&2
}

log_clean() {
    [ "$name_client" = "xray" ] && : > "$log_access" && : > "$log_error"
}

ip4_supported=$(ip -4 addr show | grep -q "inet " && echo true || echo false)
ip6_supported=$(ip -6 addr show | grep -q "inet6 " && echo true || echo false)

iptables_supported=$([ "$ip4_supported" = "true" ] && command -v iptables >/dev/null 2>&1 && echo true || echo false)
ip6tables_supported=$([ "$ip6_supported" = "true" ] && command -v ip6tables >/dev/null 2>&1 && echo true || echo false)

get_user_ipv4_excludes() {
    if [ -f "$file_ip_exclude" ]; then
        echo -n " "
        sed 's/\r$//' "$file_ip_exclude" | \
        sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
        grep -v '^#' | \
        grep -v '^$' | \
        grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?' | \
        tr '\n' ' ' | \
        sed 's/  */ /g; s/^ //; s/ $//'
    else
        echo ""
    fi
}

get_user_ipv6_excludes() {
    if [ -f "$file_ip_exclude" ]; then
        echo -n " "
        sed 's/\r$//' "$file_ip_exclude" | \
        sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
        grep -v '^#' | \
        grep -v '^$' | \
        grep -Eo '([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}(/[0-9]{1,3})?' | \
        tr '\n' ' ' | \
        sed 's/  */ /g; s/^ //; s/ $//'
    else
        echo ""
    fi
}

# Function for processing, validating and clearing the port list
validate_and_clean_ports() {
    input_ports="$1"
    final_ports=""

    final_ports=$(echo "$input_ports" | tr ',' '\n' | awk '
        function is_valid(p) {
            return p > 0 && p <= 65535 && p ~ /^[0-9]+$/
        }
        {
            gsub(/ /, "", $0)
            if ($0 == "") next;

            n = split($0, a, ":")
            if (n == 1) {
                if (is_valid(a[1])) print a[1]
            } else if (n == 2) {
                if (is_valid(a[1]) && is_valid(a[2]) && a[1] < a[2]) print a[1]":"a[2]
            }
        }
    ' | sort -un | tr '\n' ',' | sed 's/,$//')

    echo "$final_ports"
}

# Custom Port Processing Function
process_user_ports() {
    user_proxy_ports=""
    user_exclude_ports=""

    if [ -f "$file_port_proxying" ]; then
        user_proxy_ports=$(
            sed 's/\r$//' "$file_port_proxying" | \
            sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
            grep -v '^#' | \
            grep -v '^$' | \
            sed 's/-/:/g' | \
            grep -E '^[0-9]+(:[0-9]+)?$' | \
            tr '\n' ',' | \
            sed 's/,$//'
        )
    fi

    if [ -f "$file_port_exclude" ]; then
        user_exclude_ports=$(
            sed 's/\r$//' "$file_port_exclude" | \
            sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
            grep -v '^#' | \
            grep -v '^$' | \
            sed 's/-/:/g' | \
            grep -E '^[0-9]+(:[0-9]+)?$' | \
            tr '\n' ',' | \
            sed 's/,$//'
        )
    fi

    if [ -n "$user_proxy_ports" ]; then
        port_donor="${port_donor},${user_proxy_ports}"

        if echo "$port_donor" | grep -qv "\(^\|,\)80\(,\|$\)"; then
            port_donor="80,${port_donor}"
        fi
        if echo "$port_donor" | grep -qv "\(^\|,\)443\(,\|$\)"; then
            port_donor="443,${port_donor}"
        fi

        port_donor=$(validate_and_clean_ports "$port_donor")

    elif [ -n "$user_exclude_ports" ]; then
        port_exclude="${port_exclude},${user_exclude_ports}"

        port_exclude=$(validate_and_clean_ports "$port_exclude")

    else
        :
    fi
}

# Checking the status of the proxy client
proxy_status() { pidof $name_client >/dev/null; }

# Search for inbounds configuration
[ "$name_client" = "xray" ] && file_inbounds=$(find "$directory_xray_config" -name '*.json' -exec grep -lF '"inbounds":' {} \; -quit 2>/dev/null || true)

# Finding DNS Configurations
file_dns() {
    for file in "$directory_xray_config"/*.json; do
        [ -f "$file" ] || continue
        if grep -q '"dns":' "$file" && grep -q '"servers":' "$file"; then
            echo "$file"
            return 0
        fi
    done
    return 1
}
[ "$name_client" = "xray" ] && file_dns=$(file_dns)

create_user() {
    if ! id "xkeen" >/dev/null 2>&1; then
        adduser -D -H -u 11111 -g 11111 xkeen
        sed -i '/^xkeen:/c\xkeen:x:0:11111:::' /opt/etc/passwd
    fi
}

# Loading modules
load_modules() {
    module="$1"
    if [ -f "${directory_os_modules}/${module}" ]; then
        insmod "${directory_os_modules}/${module}" >/dev/null 2>&1 && return
    elif [ -f "${directory_user_modules}/${module}" ]; then
        insmod "${directory_user_modules}/${module}" >/dev/null 2>&1 && return
    fi
}

# Checking owner availability in iptables
is_owner_working() {
    iptables -w -t mangle -N TEST_OWNER_CHAIN >/dev/null 2>&1 || return 1

    if iptables -w -t mangle -A TEST_OWNER_CHAIN -m owner --gid-owner 65534 -j RETURN >/dev/null 2>&1; then
        iptables -w -t mangle -F TEST_OWNER_CHAIN >/dev/null 2>&1
        iptables -w -t mangle -X TEST_OWNER_CHAIN >/dev/null 2>&1
        return 0
    else
        iptables -w -t mangle -F TEST_OWNER_CHAIN >/dev/null 2>&1
        iptables -w -t mangle -X TEST_OWNER_CHAIN >/dev/null 2>&1
        return 1
    fi
}

load_owner() {
    if is_owner_working; then
        return 0
    fi

    load_modules xt_owner.ko

    if is_owner_working; then
        return 0
    else
        return 1
    fi
}
load_owner
load_modules xt_TPROXY.ko
load_modules xt_socket.ko
load_modules xt_multiport.ko

# Processing modules and ports
get_modules() {
    if [ "$mode_proxy" = "TProxy" ] || [ "$mode_proxy" = "Mixed" ]; then
        for module in xt_TPROXY.ko xt_socket.ko; do
            if ! lsmod | grep -q "${module%.ko}"; then
                proxy_stop
                log_error_terminal "
  Модуль ${module} не найден
  Невозможно запустить прокси в режиме ${mode_proxy} без него
  Установите компонент роутера '${yellow}Netfilter subsystem kernel modules${reset}'
  "
            fi
        done
    fi

    if [ -n "$port_donor" ] || [ -n "$port_exclude" ]; then
        if ! lsmod | grep -q xt_multiport; then
            log_warning_terminal "
  Модуль multiport не найден
  Невозможно использовать указанные порты без него
  Установите компонент роутера '${yellow}Netfilter subsystem kernel modules${reset}'
  
  Без модуля multiport прокси будет работать на всех портах
  "
            port_donor=""
            port_exclude=""
        fi
    fi

    if [ -n "$file_dns" ]; then
        if ! is_owner_working; then
            file_dns=""
            log_warning_terminal "
  Модуль owner не найден
  Невозможно использовать DNS-сервер Xray без него
  Установите компонент роутера '${yellow}Netfilter subsystem kernel modules${reset}'
  
  Без модуля owner Xray может использовать только DNS роутера
  "
        fi
    fi
}

# Obtaining a Keenetic port
get_keenetic_port() {
    result=$(curl -kfsS "${url_server}/${url_keenetic_port}" 2>/dev/null)
    keenetic_port=$(echo "$result" | jq -r '.port' 2>/dev/null)
    if [ "$keenetic_port" = "443" ]; then
        log_error_terminal "
  ${red}Порт 443 занят${reset} сервисами Keenetic
  
  Освободите его на странице 'Users and access' веб-интерфейса роутера
  "
        proxy_stop
        exit 1
    fi
}

# Getting the port for Redirect
get_port_redirect() {
    if [ "$name_client" = "mihomo" ]; then
        port=$(yq eval '.redir-port // ""' "$mihomo_config" 2>/dev/null)
        [ -n "$port" ] && echo "$port"
    else
        for file in $(find "$directory_xray_config" -name '*.json'); do
            json=$(sed 's/\/\/.*$//' "$file" | tr -d '[:space:]')
            [ -n "$json" ] || continue
            inbounds=$(echo "$json" | jq -c '.inbounds[] | select((.protocol == "dokodemo-door" or .protocol == "tunnel") and .tag == "redirect")' 2>/dev/null)
            for inbound in $inbounds; do
                port=$(echo "$inbound" | jq -r '.port' 2>/dev/null)
                tproxy=$(echo "$inbound" | jq -r '.streamSettings.sockopt.tproxy // empty' 2>/dev/null)
                [ "$tproxy" != "tproxy" ] && echo "$port" && return
            done
        done
    fi
    echo "$port_redirect"
}

# Getting the port for TProxy
get_port_tproxy() {
    if [ "$name_client" = "mihomo" ]; then
        port=$(yq eval '.tproxy-port // ""' "$mihomo_config" 2>/dev/null)
        if [ -z "$port" ]; then
            port=$(yq eval '.listeners[] | select(.name == "tproxy" ) | .port // ""' "$mihomo_config" 2>/dev/null)
        fi
        [ -n "$port" ] && echo "$port"
    else
        for file in $(find "$directory_xray_config" -name '*.json'); do
            json=$(sed 's/\/\/.*$//' "$file" | tr -d '[:space:]')
            [ -n "$json" ] || continue
            inbounds=$(echo "$json" | jq -c '.inbounds[] | select((.protocol == "dokodemo-door" or .protocol == "tunnel") and .tag == "tproxy")' 2>/dev/null)
            for inbound in $inbounds; do
                port=$(echo "$inbound" | jq -r '.port' 2>/dev/null)
                tproxy=$(echo "$inbound" | jq -r '.streamSettings.sockopt.tproxy // empty' 2>/dev/null)
                [ "$tproxy" = "tproxy" ] && echo "$port" && return
            done
        done
    fi
    echo "$port_tproxy"
}

# Getting a network for Redirect
get_network_redirect() {
    if [ "$name_client" = "mihomo" ]; then
        if [ -n "$port_redirect" ]; then
            network_redirect="tcp"
        fi
    else
    for file in $(find "$directory_xray_config" -name '*.json'); do
        json=$(sed 's/\/\/.*$//' "$file" | tr -d '[:space:]')
        [ -n "$json" ] || continue
        inbounds=$(echo "$json" | jq -c '.inbounds[] | select((.protocol == "dokodemo-door" or .protocol == "tunnel") and .tag == "redirect")' 2>/dev/null)
        for inbound in $inbounds; do
            network=$(echo "$inbound" | jq -r '.settings.network' 2>/dev/null | tr -d '[:space:]' | tr ',' ' ')
            tproxy=$(echo "$inbound" | jq -r '.streamSettings.sockopt.tproxy // empty' 2>/dev/null)
            [ "$tproxy" != "tproxy" ] && echo "$network" && return
        done
    done
    fi
    echo "$network_redirect"
}

# Obtaining a network for TProxy
get_network_tproxy() {
    if [ "$name_client" = "mihomo" ]; then
        if [ -n "$port_redirect" ] && [ -n "$port_tproxy" ]; then
            network_tproxy="udp"
        elif [ -z "$port_redirect" ] && [ -n "$port_tproxy" ]; then
            network_tproxy="tcp udp"
        fi
    else
        for file in $(find "$directory_xray_config" -name '*.json'); do
            json=$(sed 's/\/\/.*$//' "$file" | tr -d '[:space:]')
            [ -n "$json" ] || continue
            inbounds=$(echo "$json" | jq -c '.inbounds[] | select((.protocol == "dokodemo-door" or .protocol == "tunnel") and .tag == "tproxy")' 2>/dev/null)
            for inbound in $inbounds; do
                network=$(echo "$inbound" | jq -r '.settings.network' 2>/dev/null | tr -d '[:space:]' | tr ',' ' ')
                tproxy=$(echo "$inbound" | jq -r '.streamSettings.sockopt.tproxy // empty' 2>/dev/null)
                [ "$tproxy" = "tproxy" ] && echo "$network" && return
            done
        done
    fi
    echo "$network_tproxy"
}

# Getting excluded ports
get_port_exclude() {
    result=$(curl -kfsS "${url_server}/${url_https_port}" 2>/dev/null)
    port_exclude_redirect=$(echo "$result" | jq -r '.[] | if has("to-port") then .["to-port"] else .port end' 2>/dev/null |
        grep -E -v '(^|,)80($|,)|(^|,)443($|,)' | tr '\n' ',' | sed 's/,$//')
    if [ -n "$port_exclude" ]; then
        port_exclude="$port_exclude,$port_exclude_redirect"
    else
        port_exclude="$port_exclude_redirect"
    fi
    port_exclude=$(echo "$port_exclude" | tr -dc '0-9,:' | sed 's/,,*/,/g; s/^,//; s/,$//')
    echo "$port_exclude"
}

# Getting IPv4 exceptions
get_exclude_ip4() {
    [ "$iptables_supported" != "true" ] && return

    # We get the provider's IPv4
    ipv4_eth=$(ip route get 77.88.8.8 2>/dev/null | grep -o 'src [0-9.]\+' | awk '{print $2}' ||
               ip route get 8.8.8.8 2>/dev/null | grep -o 'src [0-9.]\+' | awk '{print $2}' ||
               ip route get 1.1.1.1 2>/dev/null | grep -o 'src [0-9.]\+' | awk '{print $2}')
    [ -n "$ipv4_eth" ] && ipv4_eth="${ipv4_eth}/32"
    user_ipv4=$(get_user_ipv4_excludes)
    echo "${ipv4_eth} ${ipv4_exclude}${user_ipv4}" | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' ' | sed 's/^ //; s/ $//'
}

# Receiving IPv6 exceptions
get_exclude_ip6() {
    [ "$ip6tables_supported" != "true" ] && return

    # We get the provider's IPv6
    ipv6_eth=$(ip -6 route get 2a02:6b8::feed:0ff 2>/dev/null | awk -F 'src ' '{print $2}' | awk '{print $1}' ||
               ip -6 route get 2001:4860:4860::8888 2>/dev/null | awk -F 'src ' '{print $2}' | awk '{print $1}' ||
               ip -6 route get 2606:4700:4700::1111 2>/dev/null | awk -F 'src ' '{print $2}' | awk '{print $1}')
    [ -n "$ipv6_eth" ] && ipv6_eth="${ipv6_eth}/128"
    user_ipv6=$(get_user_ipv6_excludes)
    echo "${ipv6_eth} ${ipv6_exclude}${user_ipv6}" | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' ' | sed 's/^ //; s/ $//'
}

# Retrieving a Policy Label
get_policy_mark() {
    policy_mark=$(curl -kfsS "${url_server}/${url_policy}" 2>/dev/null |
        jq -r ".[] | select(.description | ascii_downcase == \"${name_policy}\") | .mark" 2>/dev/null)

    if [ -n "$policy_mark" ]; then
        echo "0x${policy_mark}"
    else
        if ! proxy_status ; then
            if [ -z "${port_donor}" ]; then
                log_warning_terminal "
  Политика '${green}$name_policy${reset}' не найдена в веб-интерфейсе роутера
  Не определены целевые порты для XKeen
  Прокси будет запущен для всех клиентов на всех портах
  "
                echo
            else
                log_warning_terminal "
  Политика '${green}$name_policy${reset}' не найдена в веб-интерфейсе роутера
  Определены целевые порты для XKeen
  Прокси будет запущен для всех клиентов на портах ${yellow}${port_donor}${reset}
  "
                echo
            fi
        fi
        echo ""
    fi
}

# Getting proxy client mode
get_mode_proxy() {
    if [ -n "$port_redirect" ] && [ -n "$port_tproxy" ]; then
        mode_proxy="Mixed"
    elif [ -n "$port_tproxy" ]; then
        mode_proxy="TProxy"
    elif [ -n "$port_redirect" ]; then
        mode_proxy="Redirect"
    else
        mode_proxy="Other"
    fi
    echo "$mode_proxy"
}

# Configuring the firewall
configure_firewall() {
    : > "$file_netfilter_hook"
    cat > "$file_netfilter_hook" <<EOL
#!/bin/sh

name_client="$name_client"
name_profile="$name_profile"
mode_proxy="$mode_proxy"
network_redirect="$network_redirect"
network_tproxy="$network_tproxy"
networks="$networks"
name_prerouting_chain="$name_prerouting_chain"
name_output_chain="$name_output_chain"
port_redirect="$port_redirect"
port_tproxy="$port_tproxy"
port_donor="$port_donor"
port_exclude="$port_exclude"
port_dns="$port_dns"
policy_mark="$policy_mark"
table_redirect="$table_redirect"
table_tproxy="$table_tproxy"
table_mark="$table_mark"
table_id="$table_id"
file_dns="$file_dns"
directory_os_modules="$directory_os_modules"
directory_user_modules="$directory_user_modules"
directory_configs_app="$directory_configs_app"
directory_xray_config="$directory_xray_config"
directory_xray_asset="$directory_xray_asset"
iptables_supported=$iptables_supported
ip6tables_supported=$ip6tables_supported
arm64_fd=$arm64_fd
other_fd=$other_fd

# Restarting the script
restart_script() {
    exec /bin/sh "\$0" "\$@"
}

if pidof "\$name_client" >/dev/null; then
    # Adding iptables rules
    add_ipt_rule() {
        family="\$1"
        table="\$2"
        chain="\$3"
        shift 3
        [ "\$family" = "iptables" ] && [ "\$iptables_supported" = "false" ] && return
        [ "\$family" = "ip6tables" ] && [ "\$ip6tables_supported" = "false" ] && return
        if ! "\$family" -w -t "\$table" -nL \$name_prerouting_chain >/dev/null 2>&1; then
            "\$family" -w -t "\$table" -N \$name_prerouting_chain || exit 0
            add_exclude_rules \$name_prerouting_chain
            case "\$mode_proxy" in
                Mixed)
                    if [ "\$table" = "\$table_redirect" ]; then
                        "\$family" -w -t "\$table" -A \$name_prerouting_chain -p tcp -j REDIRECT --to-port "\$port_redirect" >/dev/null 2>&1
                    else
                        "\$family" -w -t "\$table" -I \$name_prerouting_chain -p udp -m socket --transparent -j MARK --set-mark "\$table_mark" >/dev/null 2>&1
                        "\$family" -w -t "\$table" -A \$name_prerouting_chain -p udp -j TPROXY --on-ip "\$proxy_ip" --on-port "\$port_tproxy" --tproxy-mark "\$table_mark" >/dev/null 2>&1
                    fi
                    ;;
                TProxy)
                    for net in \$network_tproxy; do
                        "\$family" -w -t "\$table" -I \$name_prerouting_chain -p "\$net" -m socket --transparent -j MARK --set-mark "\$table_mark" >/dev/null 2>&1
                        "\$family" -w -t "\$table" -A \$name_prerouting_chain -p "\$net" -j TPROXY --on-ip "\$proxy_ip" --on-port "\$port_tproxy" --tproxy-mark "\$table_mark" >/dev/null 2>&1
                    done
                    ;;
                Redirect)
                    for net in \$network_redirect; do
                        "\$family" -w -t "\$table" -A \$name_prerouting_chain -p "\$net" -j REDIRECT --to-port "\$port_redirect" >/dev/null 2>&1
                    done
                    ;;
                *) exit 0 ;;
            esac
        fi
        if [ "\$table" = "\$table_tproxy" ]; then
            if ! "\$family" -w -t "\$table" -nL \$name_output_chain >/dev/null 2>&1; then
                "\$family" -t "\$table" -N \$name_output_chain || exit 0
                add_exclude_rules \$name_output_chain
                for net in \$network_tproxy; do
                    "\$family" -w -t "\$table" -A \$name_output_chain -p "\$net" -j CONNMARK --set-mark "\$table_mark" >/dev/null 2>&1
                done
            fi
        fi
    }

    # Adding exception rules
    add_exclude_rules() {
        chain="\$1"
        for exclude in \$exclude_list; do
            if [ "\$exclude" = "10.0.0.0/8" ] || [ "\$exclude" = "172.16.0.0/12" ] || [ "\$exclude" = "192.168.0.0/16" ] || [ "\$exclude" = "fd00::/8" ] && [ "\$chain" != "\$name_output_chain" ] && [ -n "\$file_dns" ]; then
                if [ -n "\${file_dns}" ]; then
                    if [ "\$table" = "mangle" ] && [ "\$mode_proxy" = "Mixed" ]; then
                        "\$family" -w -t "\$table" -A "\$chain" -d "\$exclude" -p tcp --dport "\$port_dns" -j RETURN >/dev/null 2>&1
                        "\$family" -w -t "\$table" -A "\$chain" -d "\$exclude" -p udp ! --dport "\$port_dns" -j RETURN >/dev/null 2>&1
                    elif [ "\$table" = "nat" ] && [ "\$mode_proxy" = "Mixed" ]; then
                        "\$family" -w -t "\$table" -A "\$chain" -d "\$exclude" -p tcp ! --dport "\$port_dns" -j RETURN >/dev/null 2>&1
                        "\$family" -w -t "\$table" -A "\$chain" -d "\$exclude" -p udp --dport "\$port_dns" -j RETURN >/dev/null 2>&1
                    elif [ "\$table" = "mangle" ] && [ "\$mode_proxy" = "TProxy" ]; then
                        "\$family" -w -t "\$table" -A "\$chain" -d "\$exclude" -p tcp ! --dport "\$port_dns" -j RETURN >/dev/null 2>&1
                        "\$family" -w -t "\$table" -A "\$chain" -d "\$exclude" -p udp ! --dport "\$port_dns" -j RETURN >/dev/null 2>&1
                    fi
                fi
            else
                "\$family" -w -t "\$table" -A "\$chain" -d "\$exclude" -j RETURN >/dev/null 2>&1
            fi
        done
    }

    # Setting up the route table
    configure_route() {
        ip_version="\$1"

        # Defining the routing table
        if [ -n "\$policy_mark" ]; then
            policy_table=\$(ip rule show | awk -v policy="\$policy_mark" '\$0 ~ policy && /lookup/ && !/blackhole/{print \$NF}')
            route_show_cmd="ip -\$ip_version route show table all | grep -w \$policy_table"
        else
            route_show_cmd="ip -\$ip_version route show table main"
        fi

        # Checking if there is a default route
        check_default() {
            eval "\$route_show_cmd" 2>/dev/null | grep -q '^default'
        }

        if ! check_default; then
            sleep 1
            if ! check_default; then
                [ "\$ip_version" = 4 ] && touch "/tmp/noinet"
                return 1
            fi
        fi

        [ "\$ip_version" = 4 ] && rm -f "/tmp/noinet"

        if ! ip -\$ip_version rule show | grep -q "fwmark \$table_mark lookup \$table_id"; then
            ip -\$ip_version rule add fwmark "\$table_mark" lookup "\$table_id" >/dev/null 2>&1
            ip -\$ip_version route add local default dev lo table "\$table_id" >/dev/null 2>&1
        fi

        # Copying routes
        eval "\$route_show_cmd" 2>/dev/null | while read -r route; do
            case "\$route" in
                unreachable*|blackhole*)
                    continue
                    ;;
                *)
                    ip -\$ip_version route add table "\$table_id" \$route >/dev/null 2>&1
                    ;;
            esac
        done
    }

    # Creating multiple multiport rules
    add_multiport_rules() {
        family="\$1"
        table="\$2"
        net="\$3"

        if [ -n "\$port_donor" ]; then
            ports_to_process="\$port_donor"
            dports_option="--dports"
        elif [ -n "\$port_exclude" ]; then
            ports_to_process="\$port_exclude"
            dports_option="! --dports"
        else
            return
        fi

        connmark_option=\$(echo "\$connmark_option" | sed 's/^ *//')

        num_ports=\$(echo "\$ports_to_process" | tr ',' '\n' | sed '/^\$/d' | wc -l)

        if [ "\$num_ports" -eq 0 ]; then
            return
        fi

        i=1
        while [ \$i -le \$num_ports ]; do
            end=\$((i + 6))
            chunk=\$(echo "\$ports_to_process" | tr ',' '\n' | sed '/^\$/d' | sed -n "\${i},\${end}p" | tr '\n' ',' | sed 's/,\$//')

            if [ -z "\$chunk" ]; then
                break
            fi

            multiport_chunk_option="-m multiport \$dports_option \$chunk"

            full_rule="\$connmark_option -m conntrack ! --ctstate INVALID -p \$net \$multiport_chunk_option -j \$name_prerouting_chain"

            if [ "\$family" = "iptables" ] && [ "\$iptables_supported" = "true" ]; then
                if ! iptables -w -t "\$table" -C PREROUTING \$full_rule >/dev/null 2>&1; then
                    iptables -w -t "\$table" -A PREROUTING \$full_rule >/dev/null 2>&1
                fi
            fi
            if [ "\$family" = "ip6tables" ] && [ "\$ip6tables_supported" = "true" ]; then
                if ! ip6tables -w -t "\$table" -C PREROUTING \$full_rule >/dev/null 2>&1; then
                    ip6tables -w -t "\$table" -A PREROUTING \$full_rule >/dev/null 2>&1
                fi
            fi

            i=\$((i + 7))
        done
    }

    # Adding PREROUTING chains
    add_prerouting() {
        family="\$1"
        table="\$2"
        for net in \$networks; do
            if [ "\$mode_proxy" = "Mixed" ]; then
                case "\$net" in
                    tcp) table="nat" ;;
                    udp) table="mangle" ;;
                    *) continue ;;
                esac
            fi

            if [ -n "\$port_donor" ] || [ -n "\$port_exclude" ]; then
                add_multiport_rules "\$family" "\$table" "\$net"
            else
                # Logic for the case when ports are not specified (proxying all traffic)
                if [ "\$family" = "iptables" ] && [ "\$iptables_supported" = "true" ] &&
                   ! iptables -w -t "\$table" -C PREROUTING \$connmark_option -m conntrack ! --ctstate INVALID -j \$name_prerouting_chain >/dev/null 2>&1; then
                    iptables -w -t "\$table" -A PREROUTING \$connmark_option -m conntrack ! --ctstate INVALID -j \$name_prerouting_chain >/dev/null 2>&1
                fi
                if [ "\$family" = "ip6tables" ] && [ "\$ip6tables_supported" = "true" ] &&
                   ! ip6tables -w -t "\$table" -C PREROUTING \$connmark_option -m conntrack ! --ctstate INVALID -j \$name_prerouting_chain >/dev/null 2>&1; then
                    ip6tables -w -t "\$table" -A PREROUTING \$connmark_option -m conntrack ! --ctstate INVALID -j \$name_prerouting_chain >/dev/null 2>&1
                fi
            fi
        done
    }

    # Adding OUTPUT chains
    add_output() {
        family="\$1"
        table="\$2"
        if [ "\$mode_proxy" = "TProxy" ]; then
                if [ "\$family" = "iptables" ] && [ "\$iptables_supported" = "true" ] &&
                   ! iptables -w -t "\$table" -C OUTPUT -m owner ! --gid-owner \$name_profile -m conntrack ! --ctstate INVALID ! -p icmp -j \$name_output_chain >/dev/null 2>&1; then
                    iptables -w -t "\$table" -A OUTPUT -m owner ! --gid-owner \$name_profile -m conntrack ! --ctstate INVALID ! -p icmp -j \$name_output_chain >/dev/null 2>&1
                fi
                if [ "\$family" = "ip6tables" ] && [ "\$ip6tables_supported" = "true" ] &&
                   ! ip6tables -w -t "\$table" -C OUTPUT -m owner ! --gid-owner \$name_profile -m conntrack ! --ctstate INVALID ! -p icmp -j \$name_output_chain >/dev/null 2>&1; then
                    ip6tables -w -t "\$table" -A OUTPUT -m owner ! --gid-owner \$name_profile -m conntrack ! --ctstate INVALID ! -p icmp -j \$name_output_chain >/dev/null 2>&1
                fi
        fi
        if [ "\$mode_proxy" = "Mixed" ]; then
                if [ "\$family" = "iptables" ] && [ "\$iptables_supported" = "true" ] &&
                   ! iptables -w -t "\$table" -C OUTPUT -m owner ! --gid-owner \$name_profile -m conntrack ! --ctstate INVALID -p udp -j \$name_output_chain >/dev/null 2>&1; then
                    iptables -w -t "\$table" -A OUTPUT -m owner ! --gid-owner \$name_profile -m conntrack ! --ctstate INVALID -p udp -j \$name_output_chain >/dev/null 2>&1
                fi
                if [ "\$family" = "ip6tables" ] && [ "\$ip6tables_supported" = "true" ] &&
                   ! ip6tables -w -t "\$table" -C OUTPUT -m owner ! --gid-owner \$name_profile -m conntrack ! --ctstate INVALID -p udp -j \$name_output_chain >/dev/null 2>&1; then
                    ip6tables -w -t "\$table" -A OUTPUT -m owner ! --gid-owner \$name_profile -m conntrack ! --ctstate INVALID -p udp -j \$name_output_chain >/dev/null 2>&1
                fi
        fi
    }

    [ -n "\$policy_mark" ] && connmark_option="-m connmark --mark \$policy_mark"
    if [ -n "\$port_donor" ] || [ -n "\$port_exclude" ]; then
        [ -n "\$file_dns" ] && [ -n "\$port_donor" ] && port_donor="\$port_dns,\$port_donor"
    fi
    for family in iptables ip6tables; do
        if [ "\$family" = "ip6tables" ]; then
            exclude_list="$(get_exclude_ip6)"
            proxy_ip="$ipv6_proxy"
            configure_route 6
        else
            exclude_list="$(get_exclude_ip4)"
            proxy_ip="$ipv4_proxy"
            configure_route 4
        fi
        if [ -n "\$port_redirect" ] && [ -n "\$port_tproxy" ]; then
            for table in "\$table_tproxy" "\$table_redirect"; do
                add_ipt_rule "\$family" "\$table" "\$name_prerouting_chain"
                add_prerouting "\$family" "\$table"
            done
        elif [ -z "\$port_redirect" ] && [ -n "\$port_tproxy" ]; then
            table="\$table_tproxy"
            add_ipt_rule "\$family" "\$table" "\$name_prerouting_chain"
            add_prerouting "\$family" "\$table"
        elif [ -n "\$port_redirect" ] && [ -z "\$port_tproxy" ]; then
            table="\$table_redirect"
            add_ipt_rule "\$family" "\$table" "\$name_prerouting_chain"
            add_prerouting "\$family" "\$table"
        fi
        if [ "\$mode_proxy" != "Redirect" ]; then
            add_ipt_rule "\$family" "\$table_tproxy" "\$name_output_chain"
            add_output "\$family" "\$table_tproxy"
        fi
    done
else
    . "/opt/sbin/.xkeen/01_info/03_info_cpu.sh"
    status_file="/opt/lib/opkg/status"
    info_cpu
    case "\$name_client" in
        xray)
            export XRAY_LOCATION_CONFDIR="\$directory_xray_config"
            export XRAY_LOCATION_ASSET="\$directory_xray_asset"
            if [ "\$architecture" = "arm64-v8a" ]; then
                ulimit -SHn "\$arm64_fd" && su -c "\$name_client run" "\$name_profile" >/dev/null 2>&1 &
            else
                ulimit -SHn "\$other_fd" && su -c "\$name_client run" "\$name_profile" >/dev/null 2>&1 &
            fi
        ;;
        mihomo)
            if [ "\$architecture" = "arm64-v8a" ]; then
                ulimit -SHn "\$arm64_fd" && su -c "\$name_client -d \$directory_configs_app" "\$name_profile" >/dev/null 2>&1 &
            else
                ulimit -SHn "\$other_fd" && su -c "\$name_client -d \$directory_configs_app" "\$name_profile" >/dev/null 2>&1 &
            fi
        ;;
    esac
    sleep 5
    restart_script "\$@"
fi
EOL

    chmod +x "$file_netfilter_hook"
    sh "$file_netfilter_hook"
}

# Removing Iptables rules
clean_firewall() {
    [ -f "$file_netfilter_hook" ] && : > "$file_netfilter_hook"

    clean_run() {
        family="$1"
        table="$2"
        name_chain="$3"
        if "$family" -w -t "$table" -nL "$name_chain" >/dev/null 2>&1; then
            "$family" -w -t "$table" -F "$name_chain" >/dev/null 2>&1
            while "$family" -w -t "$table" -nL PREROUTING | grep -q "$name_chain"; do
                rule_number=$("$family" -w -t "$table" -nL PREROUTING --line-numbers | grep -v "Chain" | grep -m 1 "$name_chain" | awk '{print $1}')
                "$family" -w -t "$table" -D PREROUTING "$rule_number" >/dev/null 2>&1
            done
            "$family" -w -t "$table" -X "$name_chain" >/dev/null 2>&1
        fi
        if "$family" -w -t "$table" -nL "$name_chain" >/dev/null 2>&1; then
            "$family" -w -t "$table" -F "$name_chain" >/dev/null 2>&1
            while "$family" -w -t "$table" -nL OUTPUT | grep -q "$name_chain"; do
                rule_number=$("$family" -w -t "$table" -nL OUTPUT --line-numbers | grep -v "Chain" | grep -m 1 "$name_chain" | awk '{print $1}')
                "$family" -w -t "$table" -D OUTPUT "$rule_number" >/dev/null 2>&1
            done
            "$family" -w -t "$table" -X "$name_chain" >/dev/null 2>&1
        fi
    }

    for family in iptables ip6tables; do
        for chain in nat mangle; do
            clean_run "$family" "$chain" "$name_prerouting_chain"
            clean_run "$family" "$chain" "$name_output_chain"
        done
    done

    if command -v ip >/dev/null 2>&1; then
        for family in 4 6; do
            if ip -"$family" rule show | grep -q "fwmark $table_mark lookup $table_id"; then
                ip -"$family" rule del fwmark "$table_mark" lookup "$table_id" >/dev/null 2>&1
                ip -"$family" route flush table "$table_id" >/dev/null 2>&1
            fi
        done
    fi
}

# File Descriptor Monitoring
monitor_fd() {
    if ! opkg list-installed | grep -q "^coreutils-nohup"; then
        opkg update && opkg install coreutils-nohup
    fi
    while true; do
        client_pid=$(pidof "$name_client")
        if [ -n "$client_pid" ] && [ -d "/proc/$client_pid/fd" ]; then
            limit=$(awk '/Max open files/ {print $4}' "/proc/$client_pid/limits")
            current=$(ls -1 /proc/$client_pid/fd 2>/dev/null | wc -l)
            if [ "$limit" -gt 0 ] && [ "$current" -gt $((limit * 90 / 100)) ]; then
                log_warning_router "$name_client opened $current of $limit file descriptors, restart initiated"
                fd_out=true
                proxy_stop
                proxy_start "on"
            fi
        fi
        sleep "$delay_fd"
    done
}

# Running a proxy client
proxy_start() {
    start_manual="$1"
    if [ "$start_manual" = "on" ] || [ "$start_auto" = "on" ]; then
        log_clean
        process_user_ports
        port_redirect=$(get_port_redirect)
        network_redirect=$(get_network_redirect)
        port_tproxy=$(get_port_tproxy)
        network_tproxy=$(get_network_tproxy)
        mode_proxy=$(get_mode_proxy)
        if [ "$mode_proxy" != "Other" ]; then
            policy_mark=$(get_policy_mark)
            networks=$(echo "$network_redirect $network_tproxy" | tr ',' ' ' | tr -s ' ' | sort -u | tr '\n' ' ' | sed 's/^ //; s/ $//')
            if [ -n "$policy_mark" ] && [ -z "$port_donor" ]; then
                port_exclude=$(get_port_exclude)
            fi
            if ! proxy_status && { [ -n "$port_donor" ] || [ -n "$port_exclude" ] || [ "$mode_proxy" = "TProxy" ] || [ "$mode_proxy" = "Mixed" ]; }; then
                get_modules
            fi
            if [ "$mode_proxy" = "TProxy" ] || [ "$mode_proxy" = "Mixed" ]; then
                get_keenetic_port
            fi
        fi
        if proxy_status; then
            echo -e "Proxy client is already ${green}started${reset}"
            [ "$mode_proxy" != "Other" ] && configure_firewall
            if [ "$start_manual" = "on" ]; then
                log_error_terminal "$name_client could not be started because it is already running"
            else
                log_info_router "Proxy client started successfully in $mode_proxy mode"
            fi
        else
            log_info_router "Proxy client startup initiated"
            delay_increment=1
            current_delay=0
            [ "$start_manual" != "on" ] && current_delay=$start_delay
            attempt=1
            create_user
            . "/opt/sbin/.xkeen/01_info/03_info_cpu.sh"
            status_file="/opt/lib/opkg/status"
            info_cpu
            install_dir="/opt/sbin"
            while [ "$attempt" -le "$start_attempts" ]; do
                case "$name_client" in
                    xray)
                        if [ ! -f "$install_dir/xray" ]; then
                            log_error_terminal "
  Не найден файл ${yellow}$install_dir/xray${reset}

  Вероятная причина - установка XKeen на внутреннюю память и нехватка на ней места
  Выполните установку XKeen на внешний накопитель либо скопируйте файл вручную"
                            exit 1
                        fi
                        export XRAY_LOCATION_CONFDIR="$directory_xray_config"
                        export XRAY_LOCATION_ASSET="$directory_xray_asset"
                        find "$directory_xray_config" -name '._*.json' -type f -delete
                        if [ "$architecture" = "arm64-v8a" ]; then
                            if [ -n "$fd_out" ]; then
                                ulimit -SHn "$arm64_fd" && nohup su -c "$name_client run" "$name_profile" >/dev/null 2>&1 &
                                unset fd_out
                            else
                                ulimit -SHn "$arm64_fd" && su -c "$name_client run" "$name_profile" &
                            fi
                        else
                            if [ -n "$fd_out" ]; then
                                ulimit -SHn "$other_fd" && nohup su -c "$name_client run" "$name_profile" >/dev/null 2>&1 &
                                unset fd_out
                            else
                                ulimit -SHn "$other_fd" && su -c "$name_client run" "$name_profile" &
                            fi
                        fi
                    ;;
                    mihomo)
                        if [ ! -f "$install_dir/mihomo" ] || [ ! -f "$install_dir/yq" ]; then
                            missing_files=""
                            [ ! -f "$install_dir/yq" ] && missing_files="$install_dir/yq"
                            [ ! -f "$install_dir/mihomo" ] && missing_files="$install_dir/mihomo $missing_files"
                            log_error_terminal "
  Не найден(ы) файл(ы): ${yellow}${missing_files}${reset}

  Вероятная причина - установка XKeen на внутреннюю память и нехватка на ней места
  Выполните установку XKeen на внешний накопитель либо скопируйте файл(ы) вручную"
                            exit 1
                        fi
                        if [ "$architecture" = "arm64-v8a" ]; then
                            if [ -n "$fd_out" ]; then
                                ulimit -SHn "$arm64_fd" && nohup su -c "$name_client -d $directory_configs_app" "$name_profile" >/dev/null 2>&1 &
                                unset fd_out
                            else
                                ulimit -SHn "$arm64_fd" && su -c "$name_client -d $directory_configs_app" "$name_profile" &
                            fi
                        else
                            if [ -n "$fd_out" ]; then
                                ulimit -SHn "$other_fd" && nohup su -c "$name_client -d $directory_configs_app" "$name_profile" >/dev/null 2>&1 &
                                unset fd_out
                            else
                                ulimit -SHn "$other_fd" && su -c "$name_client -d $directory_configs_app" "$name_profile" &
                            fi
                        fi
                        ;;
                    *) "$name_client" run -C "$directory_xray_config" & ;;
                esac
                sleep "$current_delay"
                if proxy_status; then
                    [ "$mode_proxy" != "Other" ] && configure_firewall
                    echo -e "Proxy client ${green}launched${reset} in ${yellow}${mode_proxy}${reset}"
                    if curl -kfsS "${url_server}/${url_policy}" | jq --arg policy "$name_policy" -e 'any(.[]; .description | ascii_downcase == $policy)' > /dev/null; then
                        if [ -e "/tmp/noinet" ]; then
                            echo
                            echo -e "Policy ${yellow}$name_policy${reset} ${red}does not have internet access${reset}"
                            echo "Check if the checkbox for connecting to your provider is checked"
                        fi
                    fi
                    [ "$mode_proxy" = "Other" ] && echo -e "The transparent proxy function ${red}is not active${reset}. Route connections to ${yellow}${name_client}${reset} manually"
                    log_info_router "Proxy client started successfully in $mode_proxy mode"
                    if [ "$check_fd" = "on" ] && [ ! -f "/tmp/observer_fd" ]; then
                        touch "/tmp/observer_fd"
                        monitor_fd &
                    fi
                    return 0
                fi
                current_delay=$((current_delay + delay_increment))
                attempt=$((attempt + 1))
            done
            echo -e "${red}Failed to start ${reset} proxy client"
            log_error_terminal "Failed to start proxy client"
        fi
    else
        clean_firewall
    fi
}

# Stopping the proxy client
proxy_stop() {
    if ! proxy_status; then
        echo -e "Proxy client ${red}not running${reset}"
    else
        log_info_router "Proxy client stop initiated"
        delay_increment=1
        current_delay=0
        attempt=1
        while [ "$attempt" -le "$start_attempts" ]; do
            clean_firewall
            killall -q -9 "$name_client"
            sleep "$current_delay"
            if ! proxy_status; then
                echo -e "Proxy client ${yellow}stopped${reset}"
                log_info_router "Proxy client stopped successfully"
                return 0
            fi
            current_delay=$((current_delay + delay_increment))
            attempt=$((attempt + 1))
        done
        echo -e "Proxy client ${red}failed to stop${reset}"
        log_error_terminal "Failed to stop proxy client"
    fi
}

# Team manager
case "$1" in
    start) proxy_start "$2" ;;
    stop) proxy_stop ;;
    status)
        if proxy_status; then
            mode_proxy=$(grep '^mode_proxy=' $file_netfilter_hook | awk -F'"' '{print $2}')
            echo -e "Proxy client ${yellow}$name_client${reset} ${green}launched${reset} in mode ${yellow}$mode_proxy${reset}"
        else
            echo -e "Proxy client ${red}not running${reset}"
        fi
        ;;
    restart) proxy_stop; proxy_start "$2" ;;
    *) echo -e "Команды: ${green}start${reset} | ${red}stop${reset} | ${yellow}restart${reset} | status" ;;
esac

exit 0