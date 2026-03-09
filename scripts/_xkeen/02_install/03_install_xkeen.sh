# Function for installing XKeen
install_xkeen() {
    xkeen_archive="${tmp_dir}/xkeen.tar.gz"

    # Checking the availability of the XKeen archive
    if [ -f "${xkeen_archive}" ]; then
        
        # Temporary installation script
        install_script=$(mktemp)
        cat <<EOF > "${install_script}"
#!/bin/sh

# Unpacking archive
tar -xzf "${xkeen_archive}" -C "${install_dir}" xkeen _xkeen

# Checking for _xkeen in install_dir and moving it
if [ -d "${install_dir}/_xkeen" ]; then
    rm -rf "${install_dir}/.xkeen"
    mv "${install_dir}/_xkeen" "${install_dir}/.xkeen"
else
    echo -e "${red}Error${reset}: _xkeen was not transferred correctly"
fi

# Deleting an archive
rm "${xkeen_archive}"
EOF

        chmod +x "${install_script}"
        "${install_script}"
    fi
    [ -d "$xkeen_log_dir" ] && rm -rf "$xkeen_log_dir"
}

check_keen_mode() {
    [ "$(sysctl -n net.ipv4.ip_forward 2>/dev/null)" = "1" ] && return 0
    keen_mode="unsupported"
}
