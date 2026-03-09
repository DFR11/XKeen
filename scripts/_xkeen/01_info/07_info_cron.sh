# Checking for automatic update tasks in cron
info_cron() {
    # Getting the current crontab configuration for the root user
    cron_output=$(crontab -l -u root 2>/dev/null)

    # Checking for a task with the keyword "ug" in crontab
    if echo "$cron_output" | grep -q "ug"; then
        info_update_geofile_cron="installed"
    else
        info_update_geofile_cron="not_installed"
    fi
}
