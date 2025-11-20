# Backing up XKeen
backup_xkeen() {
    backup_dir="${backups_dir}/${current_datetime}_xkeen_v${xkeen_current_version}"
    mkdir -p "$backup_dir"

    # Copying XKeen configuration and files to backup
    cp -r "$install_dir/.xkeen" "$install_dir/xkeen" "$backup_dir/"

    # Renaming hidden directory .xkeen to _xkeen in backup
    mv "$backup_dir/.xkeen" "$backup_dir/_xkeen"

    if [ -s "$backup_dir/xkeen" ]; then
        echo -e "XKeen backup created: ${yellow}${current_datetime}_xkeen_v${xkeen_current_version}${reset}"
    else
        echo -e "${red}Error${reset} when creating an XKeen backup"
    fi
}

# Restoring XKeen from a backup
restore_backup_xkeen() {
    restore_script=$(mktemp)
    cat <<eof > "$restore_script"
#!/bin/sh

latest_backup_dir=\$(ls -t -d "$backups_dir"/*xkeen* | head -n 1)

if [ -n "\$latest_backup_dir" ]; then
    cp -r "\$latest_backup_dir"/_xkeen "$install_dir/"
    if [ \$? -eq 0 ]; then
        cp -f "\$latest_backup_dir"/xkeen "$install_dir/"
        if [ \$? -eq 0 ]; then
            if [ -d "$install_dir/_xkeen" ]; then
                if [ -d "$install_dir/.xkeen" ]; then
                    rm -rf "$install_dir/.xkeen"
                fi
                mv "$install_dir/_xkeen" "$install_dir/.xkeen"
                echo -e "XKeen ${green}successfully restored${reset}"
            fi
        else
            echo "Failed to copy _xkeen"
        fi
    else
        echo "Failed to copy _xkeen"
    fi
else
    echo "No suitable XKeen backup found"
fi

# Deleting a temporary script
rm "\$0"
eof

    chmod +x "$restore_script"
    "$restore_script"
}
