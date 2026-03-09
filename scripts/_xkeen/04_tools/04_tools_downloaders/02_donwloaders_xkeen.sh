# Download XKeen
download_xkeen() {
    xkeen_dist=$(mktemp)
    mkdir -p "$tmp_dir"
    printf "${yellow}Loading${reset} XKeen\n"

    if [ "$use_direct" != "true" ]; then
        xkeen_tar_url="$gh_proxy/$xkeen_tar_url"
    fi

    if curl --connect-timeout 10 $curl_timeout -fL -o "$xkeen_dist" "$xkeen_tar_url" 2>/dev/null; then
        if [ -s "$xkeen_dist" ]; then
            mv "$xkeen_dist" "$tmp_dir/xkeen.tar.gz"
            printf "XKeen ${green}uploaded successfully${reset}\n"
            return 0
        else
            rm -f "$xkeen_dist"
            printf "${red}Error${reset}: The downloaded XKeen file is corrupt\n"
            exit 1
        fi
    else
        rm -f "$xkeen_dist"
        printf "${red}Error${reset}: Failed to load XKeen\n"
        exit 1
    fi
}

download_xkeen_dev() {
    xkeen_tar_url="$xkeen_dev_url"
    download_xkeen
}