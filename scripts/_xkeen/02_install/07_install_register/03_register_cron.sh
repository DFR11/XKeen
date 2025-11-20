# Function for registering cron init script
register_cron_initd() {
    # Checking for the presence of a cron package
    if opkg list-installed | grep -q cron; then
        return
    fi

    # Defining Variables
    initd_file="${initd_dir}/S05crond"
    s05crond_filename="${current_datetime}_S05crond"
    required_script_version="0.5"

    # Checking for the presence of the S05crond file
    if [ -e "${initd_file}" ]; then
        # Getting the current version of the script
        script_version=$(grep 'version=' "${initd_file}" | grep -o '[0-9.]\+')

        # Checking the script version
        if [ "${script_version}" != "${required_script_version}" ]; then
            # Determining the path for the backup
            backup_path="${backups_dir}/${s05crond_filename}"

            # Move a file to the backup directory with a new name
            mv "${initd_file}" "${backup_path}"
            echo -e "Your file'${green}S05crond${reset}'moved to backup directory'${yellow}${backup_path}${reset}'"
        fi
    fi

    # Script Contents
    script_content='#!/bin/sh
### Start of service information
# Brief Description: Start/Stop Cron
# version="0.5" # Script version
### End of service information

green="\\033[32m"
red="\\033[31m"
yellow="\\033[33m"
reset="\\033[0m" 

cron_initd="/opt/sbin/crond"

# Function to check cron status
cron_status() {
    if ps | grep -v grep | grep -q "$cron_initd"; then
        return 0 # The process exists and works
    else
        return 1 # The process does not exist
    fi
}

# Function to run cron
start() {
    if cron_status; then
        echo -e "Cron ${yellow}already running${reset}"
    else
        $cron_initd -L /dev/null
        echo -e "Cron ${green}started${reset}"
    fi
}

# Function to stop cron
stop() {
    if cron_status; then
        killall -9 "crond"
        echo -e "Cron ${yellow}stopped${reset}"
    else
        echo -e "Cron ${red}not running${reset}"
    fi
}

# Function to restart cron
restart() {
    stop > /dev/null 2>&1
    start > /dev/null 2>&1
    echo -e "Cron ${green}restarted${reset}"
}

# Handling Command Line Arguments
case "$1" in
    start)
        start;;
    stop)
        stop;;
    restart)
        restart;;
    status)
        if cron_status; then
            echo -e "Cron ${green}started${reset}"
        else
            echo -e "Cron ${red}not running${reset}"
        fi;;
    *)
        echo -e "Команды: ${green}start${reset} | ${red}stop${reset} | ${yellow}restart${reset} | status";;
esac

exit 0'
    
    # Create or replace a file if the script version does not match the required version
    if [ "${script_version}" != "${required_script_version}" ]; then 
        echo -e "${script_content}" > "${initd_file}" 
        chmod +x "${initd_file}" 
    fi 
}

# Updating cron tasks
update_cron_geofile_task() {
    if [ -f "$cron_dir/$cron_file" ]; then
        tmp_file="$cron_dir/${cron_file}.tmp"
        cp "$cron_dir/$cron_file" "$tmp_file"
        
        if [ -z "$choice_canel_cron_select" ]; then
            grep -v -e "ug" -e "ux" -e "uk" -e '^\s*$' "$tmp_file" > "$cron_dir/$cron_file"
        else
            grep -v -e "ugi" -e "ugs" -e "ux" -e "uk" -e '^\s*$' "$tmp_file" > "$cron_dir/$cron_file"
        fi
    fi
}