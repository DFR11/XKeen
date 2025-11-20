# Request to add proxy cores
choice_add_proxy_cores() {
    while true; do
        echo
        echo -e "Select ${yellow}proxy kernel${reset} to download and install:"
        echo
        echo "     1. Xray"
        echo "     2. Mihomo"
        echo "     3. Xray + Mihomo"
        echo
        echo "0. Skip downloading the proxy kernel if it is already installed"
        echo

        valid_input=true
        add_xray=false
        add_mihomo=false

        while true; do
            read -r -p "Your choice:" proxy_choice
            proxy_choice=$(echo "$proxy_choice" | sed 's/,/, /g')

            if echo "$proxy_choice" | grep -qE '^[0-3]$'; then
                break
            else
                echo -e "${red}Invalid input.${reset} Select one of the suggested options"
            fi
        done

        case "$proxy_choice" in
            1)
                add_xray=true
                ;;
            2)
                add_mihomo=true
                ;;
            3)
                add_xray=true
                add_mihomo=true
                ;;
            0)
                add_xray=false
                add_mihomo=false
                ;;
            *)
                echo -e "${red}Invalid input${reset}"
                valid_input=false
                ;;
        esac

        [ "$valid_input" = "true" ] && break
    done
}

# Changing the proxy kernel to Xray
choice_xray_core() {  
    command -v xray >/dev/null 2>&1 || { echo -e "${red}Error${reset}: Xray kernel is not installed. Install with ${yellow}xkeen -ux${reset}"; exit 1; }
    if grep -q 'name_client="xray"' $initd_dir/S99xkeen; then
        echo -e "Kernel change ${red}failed${reset}. The device is already running on the ${yellow}Xray${reset} kernel"
    elif grep -q 'name_client="mihomo"' $initd_dir/S99xkeen; then
        if pidof "mihomo" >/dev/null; then
            $initd_dir/S99xkeen stop
        fi
        sed -i 's/name_client="mihomo"/name_client="xray"/' $initd_dir/S99xkeen
        add_chmod_init
        echo -e "${green}${reset} kernel changed to ${yellow}Xray${reset}"
        echo -e "Set up the configuration along the way'${yellow}$install_conf_dir/${reset}'"
        echo -e "And start proxying with the command ${yellow}xkeen -start${reset}"
    else
        echo -e "${red}error${reset} occurred when changing proxy kernel"
    fi
}

# Changing the proxy kernel to Mihomo
choice_mihomo_core() {
    command -v mihomo >/dev/null 2>&1 || { echo -e "${red}Error${reset}: Mihomo kernel is not installed. Install with ${yellow}xkeen -um${reset}"; exit 1; }
    command -v yq >/dev/null 2>&1 || { echo -e "${red}Error${reset}: Mihomo configuration file parser is not installed - ${yellow}Yq${reset}"; exit 1; }
    if grep -q 'name_client="mihomo"' $initd_dir/S99xkeen; then
        echo -e "Kernel change ${red}failed${reset}. The device is already running on the ${yellow}Mihomo${reset} kernel"
    elif [ -f "$install_dir/mihomo" ] && [ -f "$install_dir/yq" ] && grep -q 'name_client="xray"' $initd_dir/S99xkeen; then
        if pidof "xray" >/dev/null; then
            $initd_dir/S99xkeen stop
        fi
        sed -i 's/name_client="xray"/name_client="mihomo"/' $initd_dir/S99xkeen
        add_chmod_init
        echo -e "${green}${reset} kernel change completed to ${yellow}Mihomo${reset}"
        echo -e "Set up the configuration along the way'${yellow}$mihomo_conf_dir/${reset}'"
        echo -e "And start proxying with the command ${yellow}xkeen -start${reset}"
    else
        echo -e "${red}error${reset} occurred when changing proxy kernel"
    fi
}