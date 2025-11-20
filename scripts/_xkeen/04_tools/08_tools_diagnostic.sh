diagnostic() {
# Setting the path to the diagnostic file
diagnostic="/opt/diagnostic.txt"

if pidof "xray" >/dev/null; then
    name_client=xray
elif pidof "mihomo" >/dev/null; then
    name_client=mihomo
else
    echo
    echo -e "Diagnostics is only possible with ${yellow}XKeen${reset} running"
    echo -e "Run ${yellow}XKeen${reset} with the command'${green}xkeen -start${reset}'"
    exit 1
fi

ip4_supported=$(ip -4 addr show | grep -q "inet " && echo true || echo false)
ip6_supported=$(ip -6 addr show | grep -q "inet6 " && echo true || echo false)

iptables_supported=$([ "$ip4_supported" = "true" ] && command -v iptables >/dev/null 2>&1 && echo true || echo false)
ip6tables_supported=$([ "$ip6_supported" = "true" ] && command -v ip6tables >/dev/null 2>&1 && echo true || echo false)

echo
echo "Diagnostics in progress. Please wait..."

# Create a diagnostic file
touch "$diagnostic" 

# Clearing the diagnostic file before writing new data
> "$diagnostic" 

# Function to write header to file
write_header() {
    echo "-------------------------" >> "$diagnostic"
    echo -e "$1" >> "$diagnostic"
    echo "-------------------------" >> "$diagnostic"
    echo >> "$diagnostic"
}

# Core
write_header "XKeen runs on ${name_client}\nkernel and ${entware_storage} installed"

# Determination of IPv4 and IPv6 availability
write_header "IPv4 and IPv6 availability"
echo "IPv4 support - $ip4_supported" >> "$diagnostic" 
echo "IPv6 support - $ip6_supported" >> "$diagnostic" 
echo >> "$diagnostic" 
echo "iptables support - $iptables_supported" >> "$diagnostic" 
echo "i6ptables support - $ip6tables_supported" >> "$diagnostic" 
echo >> "$diagnostic"
echo >> "$diagnostic"

if [ $iptables_supported = "true" ]; then
    # Recording header and running iptables commands
    write_header "NAT chain table result PREROUTING IPv4"
    { iptables -w -t nat -nvL PREROUTING 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "The result is the tablet NAT chain xkeen IPv4"
    { iptables -w -t nat -nvL xkeen 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "Result of the MANGLE table of the PREROUTING IPv4 chain"
    { iptables -w -t mangle -nvL PREROUTING 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "Result of the MANGLE table of the xkeen IPv4 chain"
    { iptables -w -t mangle -nvL xkeen 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "Result of the MANGLE table of the OUTPUT IPv4 chain"
    { iptables -w -t mangle -nvL OUTPUT 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "Result of the MANGLE table of the xkeen_mask IPv4 chain"
    { iptables -w -t mangle -nvL xkeen_mask 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
fi

if [ $ip6tables_supported = "true" ]; then
    # Recording header and running ip6tables commands
    write_header "NAT chain table result PREROUTING IPv6"
    { ip6tables -w -t nat -nvL PREROUTING 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "Result of xkeen IPv6 chain NAT table"
    { ip6tables -w -t nat -nvL xkeen 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "Result of the MANGLE table of the PREROUTING IPv6 chain"
    { ip6tables -w -t mangle -nvL PREROUTING 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "Result of the MANGLE table of the xkeen IPv6 chain"
    { ip6tables -w -t mangle -nvL xkeen 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "Result of the MANGLE table of the OUTPUT IPv6 chain"
    { ip6tables -w -t mangle -nvL OUTPUT 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
    
    write_header "Result of the MANGLE table of the xkeen_mask IPv6 chain"
    { ip6tables -w -t mangle -nvL xkeen_mask 2>&1; } >> "$diagnostic" 
    echo >> "$diagnostic"
    echo >> "$diagnostic"
fi

# Копирование содержимого файла /opt/etc/ndm/netfilter.d/proxy.sh
write_header "Содержимое файла /opt/etc/ndm/netfilter.d/proxy.sh"
cat /opt/etc/ndm/netfilter.d/proxy.sh >> "$diagnostic" 
echo >> "$diagnostic"
echo >> "$diagnostic"

# Checking SSL port usage
write_header "Checking SSL port usage"
curl -kfsS "localhost:79/rci/ip/http/ssl" | jq -r '.port' >> "$diagnostic" 
echo >> "$diagnostic"
echo >> "$diagnostic"

# Collection of access policy data
write_header "Access Policy Data"
curl -kfsS "localhost:79/rci/show/ip/policy" | jq -r ' .[] | select(.description | ascii_downcase == "xkeen")' >> "$diagnostic" 
echo >> "$diagnostic"
echo >> "$diagnostic"

# Collecting the results of the ip rule show command
write_header "Result of ip rule show command"
ip rule show >> "$diagnostic" 
echo >> "$diagnostic"
echo >> "$diagnostic"

# Collecting the results of the ip route show table main command
write_header "Result of the ip route show table main command"
ip route show table main >> "$diagnostic" 
echo >> "$diagnostic"
echo >> "$diagnostic"

# Request to curl to get title, model, region
write_header "Data from localhost:79/rci/show/version"
curl -kfsS "localhost:79/rci/show/version" | jq -r '.title, .model, .region' >> "$diagnostic" 
echo >> "$diagnostic"
echo >> "$diagnostic"

# Query kernel version
if [ "${name_client}" = "xray" ]; then
    write_header "Xray version"
    xray -version >> "$diagnostic" 
elif [ "${name_client}" = "mihomo" ]; then
    write_header "Mihomo version"
    mihomo -v >> "$diagnostic" 
fi
echo >> "$diagnostic"
echo "Allowed file descriptors:" >> "$diagnostic"
grep 'Max open files' "/proc/$(pidof ${name_client})/limits" | awk '{print $4}' >> "$diagnostic" 
echo "File descriptors used:" >> "$diagnostic"
ls -l /proc/$(pidof ${name_client})/fd | wc -l >> "$diagnostic" 
echo >> "$diagnostic"
echo >> "$diagnostic"

# Request XKeen version
write_header "XKeen version"
xkeen -v >> "$diagnostic" 
echo >> "$diagnostic"
echo >> "$diagnostic"

if [ "${name_client}" = "xray" ]; then
    # dns.json
    if ls "$install_conf_dir"/*dns* >/dev/null 2>&1; then
        write_header "Contents of the dns.json file"
        cat "$install_conf_dir"/*dns* >> /opt/diagnostic.txt
        echo >> "$diagnostic"
        echo >> "$diagnostic"
    fi
    # inbounds.json
    if ls "$install_conf_dir"/*inbounds* >/dev/null 2>&1; then
        write_header "Contents of the inbounds.json file"
        cat "$install_conf_dir"/*inbounds* >> /opt/diagnostic.txt
        echo >> "$diagnostic"
        echo >> "$diagnostic"
    fi
    # routing.json
    if ls "$install_conf_dir"/*routing* >/dev/null 2>&1; then
        write_header "Contents of the routing.json file"
        cat "$install_conf_dir"/*routing* >> /opt/diagnostic.txt
        echo >> "$diagnostic"
        echo >> "$diagnostic"
    fi
fi

echo
echo
echo -e "Diagnostics ${green}completed${reset}"
echo -e "Send a file'${yellow}$diagnostic${reset}'in telegram chat ${yellow}XKeen${reset}, describing in detail the problem that arose"
echo
echo -e "  ${red}Примечание${reset}: Диагностика не проверяет доступ к прокси-серверу, правильность заполнения конфигов
  и настройки роутера/сервера. Она проверяет ${green}только${reset} корректность инициализации ${yellow}XKeen${reset} в роутере"
}