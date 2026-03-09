# Function for installing and updating GeoIP
install_geoip() {
    mkdir -p "$geo_dir" || { echo "Error: Failed to create directory $geo_dir"; exit 1; }

    # File installation/update
    process_geoip_file() {
        url="$1"
        filename="$2"
        display_name="$3"
        update_flag="$4"

        temp_file=$(mktemp)
        min_size=24576  # 24 KB

        download() {
            curl --connect-timeout 10 $curl_timeout -fL -o "$temp_file" "$1" >/dev/null 2>&1
            return $?
        }

        printf "Loading %s...\n" "$display_name"

        if [ "$use_direct" = "true" ]; then
            :
        else
            url="$gh_proxy/$url"
        fi

        download "$url"
        if [ $? -eq 0 ]; then
            :
        else
            rm -f "$temp_file"
            printf "${red}Error${reset}: failed to load %s\n" "$display_name"
            return 1
        fi

        # Checking file size
        actual_size=$(wc -c < "$temp_file")
        if [ "$actual_size" -lt "$min_size" ]; then
            printf "${red}Error${reset}: the uploaded file is too small (%s bytes) or damaged\nCannot be updated. We leave the old file\n\n" "$actual_size"
            rm -f "$temp_file"
            return 1
        fi

        # HTML validation
        grep -qi "<html" "$temp_file"
        if [ $? -eq 0 ]; then
            printf "${red}Error${reset}: HTML page received instead of dat file\n Unable to update. We leave the old file\n\n"
            rm -f "$temp_file"
            return 1
        fi

        # Safe replacement
        if mv "$temp_file" "$geo_dir/$filename.new"; then
            mv -f "$geo_dir/$filename.new" "$geo_dir/$filename"
        fi

        if [ "$update_flag" = "true" ]; then
            printf "%s ${green}updated successfully${reset}\n\n" "$display_name"
        else
            printf "%s ${green}installed successfully${reset}\n\n" "$display_name"
        fi

        return 0
    }

    # Installing GeoIP Re:filter
    if [ "$install_refilter_geoip" = "true" ] || [ "$update_refilter_geoip" = "true" ]; then
        process_geoip_file "$refilterip_url" "geoip_refilter.dat" \
            "GeoIP Re:filter" "$update_refilter_geoip"
    fi

    # Installing GeoIP V2Fly
    if [ "$install_v2fly_geoip" = "true" ] || [ "$update_v2fly_geoip" = "true" ]; then
        process_geoip_file "$v2flyip_url" "geoip_v2fly.dat" \
            "GeoIP V2Fly" "$update_v2fly_geoip"
    fi

    # Installing GeoIP ZKeenIP
    if [ "$install_zkeenip_geoip" = "true" ] || [ "$update_zkeenip_geoip" = "true" ]; then
        datfile="geoip_zkeenip.dat"
        [ -L "$geo_dir/geoip_zkeenip.dat" ] || [ -f "$geo_dir/zkeenip.dat" ] && datfile="zkeenip.dat"
        process_geoip_file "$zkeenip_url" "$datfile" \
            "GeoIP ZKeenIP" "$update_zkeenip_geoip"

        # Creating symlinks for compatibility
        if [ "$datfile" = "geoip_zkeenip.dat" ]; then
            rm -f "$geo_dir/zkeenip.dat"
            ln -sf "$geo_dir/geoip_zkeenip.dat" "$geo_dir/zkeenip.dat"
        else
            rm -f "$geo_dir/geoip_zkeenip.dat"
            ln -sf "$geo_dir/zkeenip.dat" "$geo_dir/geoip_zkeenip.dat"
        fi
    fi
}
