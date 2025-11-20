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
    IF=$(ip -4 route show default | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')
    [ -z "$IF" ] && IF=$(ip -6 route show default | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')
    case "$IF" in
        ""|br*|lo) keen_mode="unsupported";;
    esac
}