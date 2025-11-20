# Feedback to the console

logs_cpu_info_console() {
        echo
        echo -e "CPU instruction set: ${yellow}$architecture${reset}"
	
    if [ -z "$architecture" ]; then
        echo -e "Processor ${red}not supported${reset} XKeen"
    else
        echo -e "Processor ${green}supported${reset} XKeen"
    fi
}

logs_delete_configs_info_console() {
    info_content=
    error_content=

    if [ -d "$install_conf_dir" ]; then
        deleted_files=$(find "$install_conf_dir" -name '*.json' -type f)
    fi

    if [ -z "$deleted_files" ]; then
        echo -e "${green}Success${reset}: All Xray configuration files are deleted"
    else
        echo -e "${red}Error${reset}: The following configuration files were not deleted:"
        for file in $deleted_files; do
            echo -e "    $file"
        done
    fi
}

logs_delete_geoip_info_console() {
    info_content=
    error_content=

    if [ -f "$geo_dir/geoip_antifilter.dat" ]; then
        error_content="${red}Error${reset}: File geoip_antifilter.dat not deleted\n"
    else
        info_content="${green}Success${reset}: The geoip_antifilter.dat file is missing from the directory'$geo_dir'\n"
    fi

    if [ -f "$geo_dir/geoip_v2fly.dat" ]; then
        error_content="${error_content} ${red}Error${reset}: File geoip_v2fly.dat not deleted\n"
    else
        info_content="${info_content} ${green}Success${reset}: The file geoip_v2fly.dat is missing from the directory'$geo_dir'\n"
    fi

    if [ -f "$geo_dir/geoip_zkeenip.dat" ]; then
        error_content="${error_content} ${red}Error${reset}: File geoip_zkeenip.dat not deleted\n"
    else
        info_content="${info_content} ${green}Success${reset}: The file geoip_zkeenip.dat is missing from the directory'$geo_dir'\n"
    fi

    if [ -n "$error_content" ]; then
        echo -e "${yellow}Check${reset} operation execution"
        echo -e "$error_content"
    else
		echo -e "${yellow}Check${reset} operation execution"
        echo -e "$info_content"
    fi
}

logs_delete_geosite_info_console() {
    info_content=
    error_content=

    if [ -f "$geo_dir/geosite_antifilter.dat" ]; then
        error_content="${red}Error${reset}: The file geosite_antifilter.dat was not deleted\n"
    else
        info_content="${green}Success${reset}: The file geosite_antifilter.dat is missing from the directory'$geo_dir'\n"
    fi

    if [ -f "$geo_dir/geosite_v2fly.dat" ]; then
        error_content="${error_content} ${red}Error${reset}: File geosite_v2fly.dat not deleted\n"
    else
        info_content="${info_content} ${green}Success${reset}: File geosite_v2fly.dat is missing from directory'$geo_dir'\n"
    fi

    if [ -f "$geo_dir/geosite_zkeen.dat" ]; then
        error_content="${error_content} ${red}Error${reset}: File geosite_zkeen.dat not deleted\n"
    else
        info_content="${info_content} ${green}Success${reset}: The geosite_zkeen.dat file is missing from the directory'$geo_dir'\n"
    fi

    if [ -n "$error_content" ]; then
        echo -e "${yellow}Check${reset} operation execution"
        echo -e "$error_content"
    else
        echo -e "${yellow}Check${reset} operation execution"
        echo -e "$info_content"
    fi
}

logs_register_xkeen_status_info_console() {
    info_content=
    error_content=

    if grep -q "Package: xkeen" "$status_file"; then
        info_content="${green}Success${reset}: XKeen entry found in'$status_file'"
    else
        error_content="${red}Error${reset}: XKeen entry not found in'$status_file'"
    fi
    
    if [ -n "$info_content" ]; then
		echo -e "$info_content"
    fi
    
    if [ -n "$error_content" ]; then
		echo -e "$error_content"
    fi
}

logs_register_xkeen_control_info_console() {
    info_content=
    error_content=

    if [ -f "$register_dir/xkeen.control" ]; then
        info_content="${green}Success${reset}: The xkeen.control file was found in the directory'$register_dir/'"
    else
        error_content="${red}Error${reset}: File xkeen.control not found in directory'$register_dir/'"
    fi
    
    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi
    
    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_register_xkeen_list_info_console() {
    info_content=
    error_content=
	
    cd "$register_dir/" || exit

    if [ ! -f "xkeen.list" ]; then
        error_content="${red}Error${reset}: File xkeen.list not found in directory'$register_dir/'"
    else
        info_content="${green}Success${reset}: File xkeen.list found in directory'$register_dir/'"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi

    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi
}

logs_delete_register_xkeen_info_console() {
    info_content=
    error_content=

    if [ ! -f "$register_dir/xkeen.list" ]; then
        info_content="${green}Success${reset}: File xkeen.list not found in directory'$register_dir/'"
    else
        error_content="${red}Error${reset}: File xkeen.list found in directory'$register_dir/'"
    fi

    if [ ! -f "$register_dir/xkeen.control" ]; then
        info_content="${info_content}\n ${green}Success${reset}: File xkeen.control not found in directory'$register_dir/'"
    else
        error_content="${error_content}\n ${red}Error${reset}: File xkeen.control found in directory'$register_dir/'"
    fi

    if ! grep -q 'Package: xkeen' "$status_file"; then
        info_content="${info_content}\n ${green}Success${reset}: Package xkeen registration not found in'$status_file'"
    else
        error_content="${error_content}\n ${red}Error${reset}: Package xkeen registration detected in'$status_file'"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi

    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi
}

logs_register_xkeen_initd_info_console() {
    info_content=
    error_content=

    initd_file="$initd_dir/S99xkeen"

    if [ -f "$initd_file" ]; then
        info_content="${green}Success${reset}: XKeen init script found in directory'$initd_dir/'"
    else
        error_content="${red}Error${reset}: XKeen init script not found in directory'$initd_dir/'"
    fi

    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_register_xray_list_info_console() {
    info_content=
    error_content=
	
    cd "$register_dir/" || exit

    if [ ! -f "xray_s.list" ]; then
        error_content="${red}Error${reset}: File xray_s.list not found in directory'$register_dir/'"
    else
        info_content="${green}Success${reset}: File xray_s.list found in directory'$register_dir/'"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi

    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi
}

logs_register_xray_status_info_console() {
    info_content=
    error_content=

    if grep -q "Package: xray_s" "$status_file"; then
        info_content="${green}Success${reset}: Xray entry found in'$status_file'"
    else
        error_content="${red}Error${reset}: Xray entry not found in'$status_file'"
    fi
    
    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi
    
    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_register_xray_control_info_console() {
    info_content=
    error_content=
    
    control_file_path="$register_dir/xray_s.control"
    
    if [ -f "$control_file_path" ]; then
        info_content="${green}Success${reset}: File xray_s.control found in directory'$register_dir/'"
    else
        error_content="${red}Error${reset}: File xray_s.control not found in directory'$register_dir/'"
    fi
    
    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_register_mihomo_list_info_console() {
    info_content=
    error_content=
	
    cd "$register_dir/" || exit

    if [ ! -f "mihomo_s.list" ]; then
        error_content="${red}Error${reset}: File mihomo_s.list not found in directory'$register_dir/'"
    else
        info_content="${green}Success${reset}: File mihomo_s.list found in directory'$register_dir/'"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi

    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi
}

logs_register_mihomo_status_info_console() {
    info_content=
    error_content=

    if grep -q "Package: mihomo" "$status_file"; then
        info_content="${green}Success${reset}: mihomo entry found in'$status_file'"
    else
        error_content="${red}Error${reset}: mihomo entry not found in'$status_file'"
    fi
    
    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi
    
    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_register_mihomo_control_info_console() {
    info_content=
    error_content=
    
    control_file_path="$register_dir/mihomo_s.control"
    
    if [ -f "$control_file_path" ]; then
        info_content="${green}Success${reset}: File mihomo_s.control found in directory'$register_dir/'"
    else
        error_content="${red}Error${reset}: File mihomo_s.control not found in directory'$register_dir/'"
    fi
    
    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_register_yq_list_info_console() {
    info_content=
    error_content=
	
    cd "$register_dir/" || exit

    if [ ! -f "yq_s.list" ]; then
        error_content="${red}Error${reset}: File yq_s.list not found in directory'$register_dir/'"
    else
        info_content="${green}Success${reset}: File yq_s.list found in directory'$register_dir/'"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi

    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi
}

logs_register_yq_status_info_console() {
    info_content=
    error_content=

    if grep -q "Package: yq" "$status_file"; then
        info_content="${green}Success${reset}: Record yq found in'$status_file'"
    else
        error_content="${red}Error${reset}: Record yq not found in'$status_file'"
    fi
    
    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi
    
    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_register_yq_control_info_console() {
    info_content=
    error_content=
    
    control_file_path="$register_dir/yq_s.control"
    
    if [ -f "$control_file_path" ]; then
        info_content="${green}Success${reset}: File yq_s.control found in directory'$register_dir/'"
    else
        error_content="${red}Error${reset}: File yq_s.control not found in directory'$register_dir/'"
    fi
    
    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_delete_register_xray_info_console() {
    info_content=
    error_content=

    if [ ! -f "$register_dir/xray_s.list" ]; then
        info_content="${green}Success${reset}: File xray_s.list not found in directory'$register_dir/'"
    else
        error_content="${red}Error${reset}: File xray_s.list found in directory'$register_dir/'"
    fi

    if [ ! -f "$register_dir/xray_s.control" ]; then
        info_content="${info_content}\n ${green}Success${reset}: File xray_s.control not found in directory'$register_dir/'"
    else
        error_content="${error_content}\n ${red}Error${reset}: File xray_s.control found in directory'$register_dir/'"
    fi

    if ! grep -q 'Package: xray_s' "$status_file"; then
        info_content="${info_content}\n ${green}Success${reset}: Package xray registration not found in'$status_file'"
    else
        error_content="${error_content}\n ${red}Error${reset}: Package xray registration detected in'$status_file'"
    fi

    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_delete_register_mihomo_info_console() {
    info_content=
    error_content=

    if [ ! -f "$register_dir/mihomo_s.list" ]; then
        info_content="${green}Success${reset}: File mihomo_s.list not found in directory'$register_dir/'"
    else
        error_content="${red}Error${reset}: File mihomo_s.list found in directory'$register_dir/'"
    fi

    if [ ! -f "$register_dir/mihomo_s.control" ]; then
        info_content="${info_content}\n ${green}Success${reset}: File mihomo_s.control not found in directory'$register_dir/'"
    else
        error_content="${error_content}\n ${red}Error${reset}: File mihomo_s.control found in directory'$register_dir/'"
    fi

    if ! grep -q 'Package: mihomo_s' "$status_file"; then
        info_content="${info_content}\n ${green}Success${reset}: Mihomo package registration not found in'$status_file'"
    else
        error_content="${error_content}\n ${red}Error${reset}: Mihomo package registration detected in'$status_file'"
    fi

    if [ -n "$info_content" ]; then
        echo -e "$info_content"
    fi

    if [ -n "$error_content" ]; then
        echo -e "$error_content"
    fi
}

logs_delete_cron_geofile_info_console() {
    info_content=
    
    if [ -f "$cron_dir/$cron_file" ]; then
        if grep -q "ug" "$cron_dir/$cron_file"; then
            error_content="${red}Error${reset}: Automatic GeoFile update task not removed from cron"
        else
            info_content="${green}Success${reset}: Automatic GeoFile update task removed from cron"
        fi
        
        if [ -n "$info_content" ]; then
            echo -e "$info_content"
        elif [ -n "$error_content" ]; then
            echo -e "$error_content"
        fi
    fi
}
