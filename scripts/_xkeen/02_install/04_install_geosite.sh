# Function for installing and updating GeoSite
install_geosite() {
    mkdir -p "$geo_dir" || { echo "Error: Failed to create directory $geo_dir"; exit 1; }

    # File installation/update
    process_geosite_file() {
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

    # Installing GeoSite Re:filter
    if [ "$install_refilter_geosite" = "true" ] || [ "$update_refilter_geosite" = "true" ]; then
        process_geosite_file "$refilter_url" "geosite_refilter.dat" \
            "GeoSite Re:filter" "$update_refilter_geosite"
    fi

    # Install GeoSite V2Fly
    if [ "$install_v2fly_geosite" = "true" ] || [ "$update_v2fly_geosite" = "true" ]; then
        process_geosite_file "$v2fly_url" "geosite_v2fly.dat" \
            "GeoSite V2Fly" "$update_v2fly_geosite"
    fi

    # Installing GeoSite ZKeen
    if [ "$install_zkeen_geosite" = "true" ] || [ "$update_zkeen_geosite" = "true" ]; then
        datfile="geosite_zkeen.dat"

        [ -L "$geo_dir/geosite_zkeen.dat" ] || [ -f "$geo_dir/zkeen.dat" ] && datfile="zkeen.dat"
        process_geosite_file "$zkeen_url" "$datfile" \
            "GeoSite ZKeen" "$update_zkeen_geosite"

        # Creating symlinks for compatibility
        if [ "$datfile" = "geosite_zkeen.dat" ]; then
            rm -f "$geo_dir/zkeen.dat"
            ln -sf "$geo_dir/geosite_zkeen.dat" "$geo_dir/zkeen.dat"
        else
            rm -f "$geo_dir/geosite_zkeen.dat"
            ln -sf "$geo_dir/zkeen.dat" "$geo_dir/geosite_zkeen.dat"
        fi
    fi
}
