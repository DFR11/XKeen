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

change_autostart_xkeen() {
    if grep -q 'start_auto="on"' $initd_dir/S99xkeen; then
        sed -i 's/start_auto="on"/start_auto="off"/' $initd_dir/S99xkeen
        [ -z "$bypass_autostart_msg" ] && echo -e "XKeen autorun ${red}disabled${reset}"
    elif grep -q 'start_auto="off"' $initd_dir/S99xkeen; then
        sed -i 's/start_auto="off"/start_auto="on"/' $initd_dir/S99xkeen
        echo -e "XKeen autostart ${green}enabled${reset}"
    fi
}

choice_autostart_xkeen() {
    if grep -q 'start_auto="off"' $initd_dir/S99xkeen; then
        return 1
    fi

    echo
    echo -e "Add ${yellow}XKeen${reset} to startup when turning on the router?"
    echo
    echo "1. Yes"
    echo "0. No"
    echo

    while true; do
        read -r -p "Your choice:" choice
        case "$choice" in
            1)
                echo -e "XKeen autoboot ${green}enabled${reset}"
                return 0
                ;;
            0)
                bypass_autostart_msg="yes"
                change_autostart_xkeen
                return 0
                ;;
            *)
                echo -e "${red}Invalid input${reset}"
                ;;
        esac
    done
}

choice_redownload_xkeen() {
    echo
    echo -e "Select the reinstallation option ${yellow}XKeen${reset}"
    echo
    echo "1. Download the XKeen distribution from the Internet"
    echo "0. Local reinstallation of XKeen"
    echo

    while true; do
        read -r -p "Your choice:" choice
        case "$choice" in
            1)
                redownload_xkeen="yes"
                return 0
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${red}Invalid input${reset}"
                ;;
        esac
    done
}

choice_remove() {
    echo
    echo -e "Are you sure you want to ${red}remove ${choice_for_remove}${reset}?"
    echo
    echo "1. Yes, I want to delete"
    echo "0. No, I changed my mind"
    echo

    while true; do
        read -r -p "Your choice (1 or 0):" choice
        case "$choice" in
            1)
                return 0
                ;;
            0)
                exit 0
                ;;
            *)
                echo -e "${red}Invalid input${reset}"
                ;;
        esac
    done
}

choice_port_xkeen() {
    echo
    if [ "$add_ports" = "donor" ]; then
        echo -e "  Добавлять порты проксирования рекомендуется в файле ${yellow}/opt/etc/xkeen/port_proxying.lst${reset}"
    elif [ "$add_ports" = "exclude" ]; then
        echo -e "  Иключать порты из проксирования рекомендуется в файле ${yellow}/opt/etc/xkeen/port_exclude.lst${reset}"
    fi
    echo -e "Continue ${red}not recommended${reset} method?"
    echo
    echo "1. Yes, let's continue"
    echo -e "0. Cancel, I will use ${green}recommended${reset} method"
    echo

    while true; do
        read -r -p "Your choice:" choice
        case "$choice" in
            1)
                return 0
                ;;
            0)
                exit 0
                ;;
            *)
                echo -e "${red}Invalid input${reset}"
                ;;
        esac
    done
}