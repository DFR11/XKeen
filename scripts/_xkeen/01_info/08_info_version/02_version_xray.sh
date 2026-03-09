# Function to get Xray version information
info_version_xray() {

    # Checking if Xray is installed
    if [ "$xray_installed" = "installed" ]; then
        # If Xray is installed, we get the current version
        xray_current_version=$("$install_dir/xray" -version 2>&1 | grep -o -E 'Xray [0-9]+\.[0-9]+\.[0-9]+' | cut -d ' ' -f 2)
    fi
}
