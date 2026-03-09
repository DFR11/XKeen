# Request to change XKeen update channel (Stable/Dev)
choice_channel_xkeen() {
    echo
    echo -e "Current update channel ${yellow}XKeen${reset}:"
    
    if [ "$xkeen_build" = "Stable" ]; then
        echo -e "Stable version (${green}Stable${reset})"
        echo
        echo "1. Switch to the development channel"
        echo "0. Stay on stable version"
    else
        echo -e "Version under development (${green}$xkeen_build${reset})"
        echo
        echo "1. Switch to stable version"
        echo "0. Stay on development version"
    fi

    echo
    while true; do
        read -r -p "Your choice:" choice
        if echo "$choice" | grep -qE '^[0-1]$'; then
            case "$choice" in
                1)
                    if [ "$xkeen_build" = "Stable" ]; then
                        choice_build="Dev"
                    else
                        choice_build="Stable"
                    fi
                    return 0
                    ;;
                0)
                    echo "We remain on the current XKeen branch"
                    return 0
                    ;;
            esac
        else
            echo -e "${red}Invalid input${reset}"
        fi
    done
}

change_channel_xkeen() {
    echo
    if [ "$choice_build" = "Stable" ]; then
        sed -i 's/^xkeen_build="[^"]*"/xkeen_build="Stable"/' "$xkeen_var_file"
        if grep -q '^xkeen_build="Stable"$' "$xkeen_var_file"; then
            echo -e "Update channel ${yellow}XKeen${reset} switched to ${green}stable branch${reset}"
        else
            echo -e "${red}Error${reset} occurred when switching update channel"
            unset choice_build
        fi
    elif [ "$choice_build" = "Dev" ]; then
        sed -i 's/xkeen_build="Stable"/xkeen_build="Dev"/' $xkeen_var_file
        if grep -q '^xkeen_build="Dev"$' "$xkeen_var_file"; then
            echo -e "Update channel ${yellow}XKeen${reset} switched to ${green}development branch${reset}"
        else
            echo -e "${red}Error${reset} occurred when switching update channel"
            unset choice_build
        fi
    fi
    if [ -n "$choice_build" ]; then
        echo
        echo -e "With the command ${green}xkeen -uk${reset} you can update ${yellow}XKeen${reset} to the latest version in the selected branch"
    fi
}

change_ipv6_support() {
    ip -6 addr show 2>/dev/null | grep -q "inet6 " && ip6_supported="true" || ip6_supported="false"

    echo
    echo -e "Current state of IPv6 in ${yellow}KeeneticOS${reset}:"
    if [ "$ip6_supported" = "true" ]; then
        echo -e "IPv6 ${green}enabled${reset}"
        echo
        echo "1. Disable IPv6"
        echo "0. Leave unchanged"
        desired_state="off"
    else
        echo -e "IPv6 ${green}disabled${reset}"
        echo
        echo "1. Enable IPv6"
        echo "0. Leave unchanged"
        desired_state="on"
    fi

    echo
    while true; do
        read -r -p "Your choice:" choice
        if echo "$choice" | grep -qE '^[0-1]$'; then
            case "$choice" in
                0)
                    return 0
                    ;;
                1)
                    break
                    ;;
            esac
        else
            echo -e "${red}Invalid input${reset}"
        fi
    done

    if [ -f "$initd_file" ]; then
        sed -i "s/ipv6_support=\"[a-z]*\"/ipv6_support=\"$desired_state\"/" "$initd_file"
            if [ "$desired_state" = "off" ]; then
                sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
                sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
            else
                sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1
                sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null 2>&1
            fi
        if pidof xray >/dev/null || pidof mihomo >/dev/null; then
            echo -e "${yellow}${reset} in progress. Please wait..."
            "$initd_file" restart on >/dev/null 2>&1
        fi
        if [ "$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null)" -eq 1 ] &&
           [ "$(sysctl -n net.ipv6.conf.default.disable_ipv6 2>/dev/null)" -eq 1 ]; then
            echo -e "IPv6 support in KeeneticOS ${green}disabled${reset}"
            echo "Make sure it is also disabled in the router web interface"
        elif [ "$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null)" -eq 0 ] &&
           [ "$(sysctl -n net.ipv6.conf.default.disable_ipv6 2>/dev/null)" -eq 0 ]; then
            echo -e "IPv6 support in KeeneticOS ${green}enabled${reset}"
        else
            echo -e "${red}Error${reset} when changing IPv6 status"
        fi
    else
        echo -e "${red}Error${reset}: Autorun file not found ${yellow}S99xkeen${reset}"
        return 1
    fi
}

choice_backup_xkeen() {
    backup_value=$(awk -F= '/^[[:space:]]*backup[[:space:]]*=/ && $0 !~ /^[[:space:]]*#/ { gsub(/"| /,"",$2); print tolower($2) }' "$initd_file")
    [ "$backup_value" = "off" ]
}

choice_autostart_xkeen() {
    if [ -f "$initd_file" ] && grep -q 'start_auto="off"' "$initd_file"; then
        return 1
    fi

    if choice_menu \
        "Add ${yellow}XKeen${reset} to startup when turning on the router?" \
        "Yes" \
        "No"; then
        echo -e "XKeen autoboot ${green}enabled${reset}"
        return 0
    else
        bypass_autostart_msg="yes"
        change_autostart_xkeen
        return 0
    fi
}

choice_redownload_xkeen() {
    if choice_menu \
        "Select the reinstallation option ${yellow}XKeen${reset}" \
        "Download the XKeen distribution from the Internet" \
        "Local reinstallation of XKeen"; then
        redownload_xkeen="yes"
    fi
}

choice_remove() {
    if choice_menu \
        "Are you sure you want to ${red}remove ${choice_for_remove}${reset}?" \
        "Yes, I want to delete" \
        "No, I changed my mind"; then
        return 0
    else
        exit 0
    fi
}

change_autostart_xkeen() {
    toggle_param "start_auto" "autostart XKeen" "none"
}

change_proxy_dns() {
    toggle_param "proxy_dns" "DNS hijacking" "restart"
}

change_file_descriptors() {
    toggle_param "check_fd" "file descriptor control" "reboot"
}