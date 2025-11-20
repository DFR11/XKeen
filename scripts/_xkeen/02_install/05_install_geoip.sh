# Function for installing and updating GeoIP
install_geoip() {
    mkdir -p "$geo_dir" || { echo "Error: Failed to create directory $geo_dir"; exit 1; }

    # File installation/update
    process_geoip_file() {
        url=$1
        filename=$2
        display_name=$3
        update_flag=$4

        temp_file=$(mktemp)
        
        # First try: direct download
        if curl -m 10 -L -o "$temp_file" "$url" > /dev/null 2>&1; then
            if [ -s "$temp_file" ]; then
                mv "$temp_file" "$geo_dir/$filename"
                if [ "$update_flag" = true ]; then
                    echo -e "$display_name ${green}updated successfully${reset}"
                else
                    echo -e "$display_name ${green}installed successfully${reset}"
                fi
                return 0
            else
                echo -e "${red}Unknown error${reset} when installing $display_name"
                return 1
            fi
        else
            # Second try: downloading via proxy
            if curl -m 10 -L -o "$temp_file" "$gh_proxy/$url" > /dev/null 2>&1; then
                if [ -s "$temp_file" ]; then
                    mv "$temp_file" "$geo_dir/$filename"
                    if [ "$update_flag" = true ]; then
                        echo -e "$display_name ${green}updated successfully via proxy${reset}"
                    else
                        echo -e "$display_name ${green}installed successfully via proxy${reset}"
                    fi
                    return 0
                else
                    echo -e "${red}Unknown error${reset} when installing $display_name"
                    return 1
                fi
            else
                rm -f "$temp_file"
                echo -e "${red}Error${reset} loading $display_name. Check your internet connection or try again later"
                return 1
            fi
        fi
    }

    # Installing GeoIP Re:filter
    if [ "$install_refilter_geoip" = true ] || [ "$update_refilter_geoip" = true ]; then
        process_geoip_file \
            "$refilterip_url" \
            "geoip_refilter.dat" \
            "GeoIP Re:filter" \
            "$update_refilter_geoip"
    fi

    # Installing GeoIP V2Fly
    if [ "$install_v2fly_geoip" = true ] || [ "$update_v2fly_geoip" = true ]; then
        process_geoip_file \
            "$v2flyip_url" \
            "geoip_v2fly.dat" \
            "GeoIP V2Fly" \
            "$update_v2fly_geoip"
    fi

    # Installing GeoIP ZKeenIP
    if [ "$install_zkeenip_geoip" = true ] || [ "$update_zkeenip_geoip" = true ]; then
        datfile="geoip_zkeenip.dat"
        [ -L "$geo_dir/geoip_zkeenip.dat" ] || [ -f "$geo_dir/zkeenip.dat" ] && datfile="zkeenip.dat"
        process_geoip_file \
            "$zkeenip_url" \
            "$datfile" \
            "GeoIP ZKeenIP" \
            "$update_zkeenip_geoip"
        # Creating symlinks for compatibility
        if [ "$datfile" = "geoip_zkeenip.dat" ]; then
            rm -f "$geo_dir/zkeenip.dat"
            ln -sf "$geo_dir/geoip_zkeenip.dat" "$geo_dir/zkeenip.dat"
        elif [ "$datfile" = "zkeenip.dat" ]; then
            rm -f "$geo_dir/geoip_zkeenip.dat"
            ln -sf "$geo_dir/zkeenip.dat" "$geo_dir/geoip_zkeenip.dat"
        fi
    fi
}