# Download XKeen
download_xkeen() {
    xkeen_dist=$(mktemp)
    mkdir -p "$tmp_dir"
    echo -e "${yellow}Loading ${reset} XKeen"

    # First try: direct download
    if curl -m 10 -L -o "$xkeen_dist" "$xkeen_tar_url" &> /dev/null; then
        if [ -s "$xkeen_dist" ]; then
            mv "$xkeen_dist" "$tmp_dir/xkeen.tar.gz"
            echo -e "XKeen ${green}uploaded successfully${reset}"
            return 0
        else
            echo -e "${red}Error${reset}: The downloaded XKeen file is corrupt"
        fi
    else
        # Second try: downloading via proxy
        if curl -m 10 -L -o "$xkeen_dist" "$gh_proxy/$xkeen_tar_url" &> /dev/null; then
            if [ -s "$xkeen_dist" ]; then
                mv "$xkeen_dist" "$tmp_dir/xkeen.tar.gz"
                echo -e "XKeen ${green}successfully downloaded via proxy${reset}"
                return 0
            else
                echo -e "${red}Error${reset}: The downloaded XKeen file is corrupt"
            fi
        else
            echo -e "${red}Error${reset}: Failed to load XKeen. Check your internet connection or try again later"
        fi
    fi
    rm -f "$xkeen_dist"
    exit 1
}

download_xkeen_dev() {
    xkeen_tar_url="$xkeen_dev_url"
    download_xkeen
}