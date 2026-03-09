# Removing temporary files and directories
delete_tmp() {
    [ -d "$tmp_dir_global/xkeen" ] && rm -rf "$tmp_dir_global/xkeen"
    [ -f "$cron_dir/root.tmp" ] && rm -f "$cron_dir/root.tmp"
    [ -f "$register_dir/new_entry.txt" ] && rm -f "$register_dir/new_entry.txt"
    [ -f "$install_dir/xray_bak" ] && rm -f "$install_dir/xray_bak"
    [ -f "$install_dir/mihomo_bak" ] && rm -f "$install_dir/mihomo_bak"
    [ -d "$xtmp_dir" ] && rm -rf "$xtmp_dir"
    [ -d "$mtmp_dir" ] && rm -rf "$mtmp_dir"
    [ -f "/tmp/xkrun" ] && rm -f "/tmp/xkrun"
    [ -f "/tmp/toff" ] && rm -f "/tmp/toff"

    if ! pidof xray >/dev/null && ! pidof mihomo >/dev/null ; then
        [ -f "/opt/etc/ndm/netfilter.d/proxy.sh" ] && rm "/opt/etc/ndm/netfilter.d/proxy.sh"
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