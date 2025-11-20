backup_configs_mihomo() {
    backup_filename="${current_datetime}_configs_mihomo"
    backup_configs_dir="$backups_dir/$backup_filename"
    mkdir -p "$backup_configs_dir"

    # Backup all Mihomo configuration files
    cp -r "$mihomo_conf_dir"/* "$backup_configs_dir/"

    if [ $? -eq 0 ]; then
        echo -e "Mihomo configuration backup created: ${yellow}$backup_filename${reset}"
    else
        echo -e "${red}Error${reset} when creating a backup copy of Mihomo configurations"
    fi
}

restore_backup_configs_mihomo() {
    # Find the latest Mihomo configuration backup
    latest_backup=$(ls -t "$backups_dir" | grep "configs_mihomo" | head -n 1)

    if [ -n "$latest_backup" ]; then
        backup_path="$backups_dir/$latest_backup"
		
        rm -rf "$mihomo_conf_dir"/*
        cp -r "$backup_path"/* "$mihomo_conf_dir/"

        echo -e "Mihomo configuration ${green}successfully restored${reset}"
    fi
}
