# Function for installing and updating GeoSite
install_geosite() {
    mkdir -p "$geo_dir" || { echo "Error: Failed to create directory $geo_dir"; exit 1; }

    # File installation/update
    process_geosite_file() {
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

    # Installing GeoSite Re:filter
    if [ "$install_refilter_geosite" = true ] || [ "$update_refilter_geosite" = true ]; then
        process_geosite_file \
            "$refilter_url" \
            "geosite_refilter.dat" \
            "GeoSite Re:filter" \
            "$update_refilter_geosite"
    fi

    # Install GeoSite V2Fly
    if [ "$install_v2fly_geosite" = true ] || [ "$update_v2fly_geosite" = true ]; then
        process_geosite_file \
            "$v2fly_url" \
            "geosite_v2fly.dat" \
            "GeoSite V2Fly" \
            "$update_v2fly_geosite"
    fi

    # Installing GeoSite ZKeen
    if [ "$install_zkeen_geosite" = true ] || [ "$update_zkeen_geosite" = true ]; then
        datfile="geosite_zkeen.dat"
        [ -L "$geo_dir/geosite_zkeen.dat" ] || [ -f "$geo_dir/zkeen.dat" ] && datfile="zkeen.dat"
        process_geosite_file \
            "$zkeen_url" \
            "$datfile" \
            "GeoSite ZKeen" \
            "$update_zkeen_geosite"
        # Creating symlinks for compatibility
        if [ "$datfile" = "geosite_zkeen.dat" ]; then
            rm -f "$geo_dir/zkeen.dat"
            ln -sf "$geo_dir/geosite_zkeen.dat" "$geo_dir/zkeen.dat"
        elif [ "$datfile" = "zkeen.dat" ]; then
            rm -f "$geo_dir/geosite_zkeen.dat"
            ln -sf "$geo_dir/zkeen.dat" "$geo_dir/geosite_zkeen.dat"
        fi
    fi
}