# Determining where to install Entware
tests_entware_storage() {
    mount_point=$(mount | grep 'on /opt ')
    device=$(echo "$mount_point" | awk '{print $1}')

    if echo "$device" | grep -q "^/dev/sd"; then
        entware_storage="to an external USB drive"
    elif echo "$device" | grep -q "^/dev/ubi"; then
        entware_storage="to the internal memory of the router"
        preinstall_warn="true"
    else
        entware_storage="to an unidentified storage medium"
    fi
}

preinstall_warn() {
    if [ -n "$preinstall_warn" ]; then
        echo
        echo -e "${red}Warning${reset}: XKeen $entware_storage installation initiated"
        echo "Make sure there is enough free space. Failure with this"
        echo "installation is not an XKeen problem and the bug report will not be considered"
        echo -e "XKeen ${green}${reset} is recommended to be installed on an external ${green}USB drive${reset}"
        echo
        echo "1. Continue installing $entware_storage"
        echo "2. Exit the installer"
        echo

    while true; do
        read -p "Select action:" choice

        case $choice in
            1)
                clear
                break
                ;;
            2)
                echo
                echo -e "${red}Installation cancelled${reset}"
                exit 0
                ;;
            *)
                echo -e "${red}Invalid input.${reset} Select one of the suggested options"
                ;;
        esac
    done
    fi
}