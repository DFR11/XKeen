# Function for installing Mihomo
install_mihomo() {
    echo -e "${yellow}${reset} Mihomo is being installed. Please wait..."

    # Defining Variables
    mihomo_archive="${mtmp_dir}/mihomo.gz"

    # Checking the availability of the Mihomo archive
    if [ -f "${mihomo_archive}" ]; then

        if [ -f "$install_dir/mihomo" ]; then
            mv "$install_dir/mihomo" "$install_dir/mihomo_bak"
        fi

        # Unpack Mihomo archive
        if [ -d "${mtmp_dir}/mihomo" ]; then
            rm -r "${mtmp_dir}/mihomo"
        fi

        if gzip -d "${mihomo_archive}"; then
            mv "${mtmp_dir}/mihomo" $install_dir/
            chmod +x $install_dir/mihomo
            echo -e "Mihomo ${green}installed successfully${reset}"
        fi

        # Deleting temporary files
        rm -rf "${mtmp_dir}/mihomo"
    fi
}