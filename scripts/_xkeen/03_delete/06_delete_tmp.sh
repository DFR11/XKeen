# Removing temporary files and directories
delete_tmp() {
    if [ -d "$tmp_dir_global/xkeen" ]; then
        rm -r "$tmp_dir_global/xkeen"
    fi

    if [ -f "$cron_dir/root.tmp" ]; then
        rm "$cron_dir/root.tmp"
    fi

    if [ -f "$register_dir/new_entry.txt" ]; then
        rm "$register_dir/new_entry.txt"
    fi

    if ! pidof xray >/dev/null && ! pidof mihomo >/dev/null ; then
        if [ -f "/opt/etc/ndm/netfilter.d/proxy.sh" ]; then
            rm "/opt/etc/ndm/netfilter.d/proxy.sh"
        fi
    fi

    echo
    echo -e "Temporary files cleared ${green}done${reset}"
}

delete_all() {
    echo
    echo -e "Delete backups and user settings?"
    echo -e "  ${yellow}$backups_dir${reset}"
    echo -e "  ${yellow}$xkeen_cfg${reset}"
    echo
    echo "1. Yes, delete"
    echo "0. No, leave it"
    echo

    while true; do
        read -r -p "Your choice:" choice
        case "$choice" in
            1)
                [ -d "$backups_dir" ] && rm -rf "$backups_dir"
                [ -d "$xkeen_cfg" ] && rm -rf "$xkeen_cfg"
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