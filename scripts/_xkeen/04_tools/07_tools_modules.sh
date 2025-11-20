keenos_modules() {
    keenos=$(curl -kfsS "localhost:79/rci/show/version" 2>/dev/null | grep '"release"' | cut -d'"' -f4 | cut -d'.' -f1)
    modules="xt_TPROXY.ko xt_socket.ko xt_multiport.ko"
    
    [ -z "$keenos" ] || [ "$keenos" -lt 5 ] && modules="$modules xt_owner.ko"
}

migration_modules() {
    found_modules=""

    if [ ! -d "${user_modules}" ]; then
        echo -e "Target directory ${yellow}does not exist${reset}"
        echo "Directory creation in progress"
        mkdir -p "${user_modules}"
    fi

    for module in $modules; do
        if [ -f "${user_modules}/$module" ]; then
            found_modules="$found_modules $module"
        fi
    done

    if [ -n "$found_modules" ]; then
        echo "The following modules have already been found in the user directory:"
        for module in $found_modules; do
            echo -e "    - ${yellow}$module${reset}"
        done
        
        echo
        echo "Do you want to replace them with new copies? (1 - Yes, 0 - No)"
        echo -e "Old versions of modules will be ${red}overwritten${reset}"

        read -r -p "Your choice:" choice
        case "$choice" in
            1 )
                echo
                echo "I'm starting to copy and replace..."
                ;;
            * )
                echo "Copying canceled"
                return 0
                ;;
        esac
    else
        echo "I'm starting to copy modules..."
    fi

    # Copying modules
    copied_count=0
    total_count=0
    for module in $modules; do
        total_count=$((total_count + 1))
        cp "${os_modules}/$module" "${user_modules}"
        if [ $? -eq 0 ]; then
            echo -e "Module ${yellow}$module${reset} copied"
            copied_count=$((copied_count + 1))
        else
            echo -e "${red}Error${reset} when copying module $module"
            echo -e "Check if the router component is installed'${yellow}Модули ядра подсистемы Netfilter${reset}'"
            exit 1
        fi
        sleep 1
    done

    echo -e "Modules required for XKeen ${green}successfully${reset} copied"
    echo -e "If the router component'${yellow}Модули ядра подсистемы Netfilter${reset}'not required, you can delete it"
}

remove_modules() {
    found_modules=""

    for module in $modules; do
        if [ -f "${user_modules}/$module" ]; then
            found_modules="$found_modules $module"
        fi
    done

    if [ -n "$found_modules" ]; then
        echo "Found in the user directory:"
        for module in $found_modules; do
            echo -e "    - ${yellow}$module${reset}"
        done
        
        echo
        echo "Do you want to remove all found modules? (1 - Yes, 0 - No)"
        echo -e "Make sure the component'${yellow}Модули ядра подсистемы Netfilter${reset}'installed"

        read -r -p "Your choice:" choice
        case "$choice" in
            1 )
                echo
                echo "I'm starting to delete..."
                ;;
            * )
                echo "Deletion cancelled."
                return 0
                ;;
        esac

    else
        echo "No modules to remove"
        return 0
    fi

    removed_count=0
    total_count=0
    for module in $found_modules; do
        total_count=$((total_count + 1))
        rm -f "${user_modules}/$module"
        if [ $? -eq 0 ]; then
            echo -e "Module ${yellow}$module${reset} removed"
            removed_count=$((removed_count + 1))
        else
            echo -e "${red}Error${reset} when deleting module ${yellow}$module${reset}"
        fi
        sleep 1
    done

    echo -e "All modules ${green}successfully${reset} removed"
    echo
    echo -e "For XKeen to start using firmware modules - ${green}reboot the router${reset}"
}