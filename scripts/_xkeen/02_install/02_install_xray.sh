# Function for installing Xray
install_xray() {
    echo -e "${yellow}${reset} Xray is being installed. Please wait..."

    # Defining Variables
    xray_archive="${xtmp_dir}/xray.zip"

    # Checking the presence of an Xray archive
    if [ -f "${xray_archive}" ]; then

        if [ -f "$install_dir/xray" ]; then
            mv "$install_dir/xray" "$install_dir/xray_bak"
        fi

        # Unpacking the Xray archive
        if [ -d "${xtmp_dir}/xray" ]; then
            rm -r "${xtmp_dir}/xray"
        fi

        if unzip -q "${xray_archive}" -d "${xtmp_dir}/xray"; then
            mv "${xtmp_dir}/xray/xray" $install_dir/
            chmod +x $install_dir/xray
            echo -e "Xray ${green}installed successfully${reset}"
        fi

        # Deleting an Xray archive
        rm "${xray_archive}"

        # Deleting temporary files
        rm -rf "${xtmp_dir}/xray"

        # Fix for new xray kernels
        if [ -d "$install_conf_dir" ]; then
            for file in "$install_conf_dir"/*; do
                [ -f "$file" ] || continue
                if grep "transport" "$file" >/dev/null 2>&1; then
                    rm -f "$file"
                fi
            done
        fi

    fi
}