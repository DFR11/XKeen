backup_configs_xray() {
    backup_filename="${current_datetime}_configs_xray"
    backup_configs_dir="$backups_dir/$backup_filename"
    mkdir -p "$backup_configs_dir"

    # Backup all Xray configuration files
    cp -r "$install_conf_dir"/* "$backup_configs_dir/"

    if [ $? -eq 0 ]; then
        echo -e "Xray configuration is backed up: ${yellow}$backup_filename${reset}"
    else
        echo -e "${red}Error${reset} when backing up Xray configurations"
    fi
}

restore_backup_configs_xray() {
    # Find the latest Xray configuration backup
    latest_backup=$(ls -t "$backups_dir" | grep "configs_xray" | head -n 1)

    if [ -n "$latest_backup" ]; then
        backup_path="$backups_dir/$latest_backup"
		
        rm -rf "$install_conf_dir"/*
        cp -r "$backup_path"/* "$install_conf_dir/"

        echo -e "Xray configuration ${green}restored successfully${reset}"
    fi
}
