# Determining which ports the proxy core listens on
tests_ports_client() {

    if pidof "xray" >/dev/null; then
        name_client=xray
    elif pidof "mihomo" >/dev/null; then
        name_client=mihomo
    else
        echo
        echo "Determining listening ports is only possible when XKeen is running"
        echo "Launch XKeen with the command'xkeen -start'"
        exit 1
    fi

    listening_ports_tcp=
    listening_ports_udp=
    output="$name_client ${green}listening${reset}"

    listening_ports_tcp=$(netstat -ltunp | grep "$name_client" | grep "tcp")
    listening_ports_udp=$(netstat -ltunp | grep "$name_client" | grep "udp")

    if [ -n "$listening_ports_tcp" ] || [ -n "$listening_ports_udp" ]; then
        printed=false
        IFS='
'
        for line in $listening_ports_tcp $listening_ports_udp; do
            gateway=
            port=
            protocol=
            
            if [ -n "$(echo "$line" | grep "tcp")" ]; then
                protocol="TCP"
            fi
            if [ -n "$(echo "$line" | grep "udp")" ]; then
                if [ -n "$protocol" ]; then
                    protocol="$protocol и UDP"
                else
                    protocol="UDP"
                fi
            fi
            
            full_address=$(echo "$line" | awk '{print $4}')
            
            if echo "$full_address" | grep -q '^:::[0-9]'; then
                # If IPv4 appears as :::port
                gateway="0.0.0.0"
                port=$(echo "$full_address" | awk -F':::' '{print $2}')
            elif echo "$full_address" | grep -q '^\[::\]'; then
                # Explicit IPv6 [::]:port
                gateway="[::]"
                port=$(echo "$full_address" | awk -F'\\]:' '{print $2}')
            elif echo "$full_address" | grep -q '\\]:'; then
                # Regular IPv6 [addr]:port
                gateway=$(echo "$full_address" | awk -F'\\]:' '{print $1}')"]"
                port=$(echo "$full_address" | awk -F'\\]:' '{print $2}')
            elif echo "$full_address" | grep -q ':'; then
                # Regular IPv4
                gateway=$(echo "$full_address" | cut -d':' -f1)
                port=$(echo "$full_address" | cut -d':' -f2)
            fi
            
            if [ "$printed" = false ]; then
                printf "%b\n" "$output"
                printed=true
            fi
            printf "\n %bSlut%b %s\n %b." \
                   "$italic" "$reset" "$gateway" \
                   "$italic" "$reset" "$port" \
                   "$italic" "$reset" "$protocol"
        done
    else
        printf "%b\n" "$name_client ${red}does not listen to ${reset} on any ports"
    fi
}