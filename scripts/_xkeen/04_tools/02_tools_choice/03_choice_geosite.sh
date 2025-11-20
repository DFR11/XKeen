# Function for selecting GeoSite options
choice_geosite() {
    has_missing_geosite_bases=false
    has_updatable_geosite_bases=false

    for source in refilter v2fly zkeen; do
        var="update_${source}_geosite"
        msg_var="update_${source}_geosite_msg"
        
        if [ "$(eval echo \$$var)" = "false" ]; then
            has_missing_geosite_bases=true
        else
            eval "$msg_var=true"
            has_updatable_geosite_bases=true
        fi
    done

    while true; do
        install_refilter_geosite=false
        install_v2fly_geosite=false
        install_zkeen_geosite=false
        update_refilter_geosite=false
        update_v2fly_geosite=false
        update_zkeen_geosite=false
        choice_delete_geosite_refilter_select=false
        choice_delete_geosite_v2fly_select=false
        choice_delete_geosite_zkeen_select=false
        invalid_choice=false

        echo 
        echo -e "Select the action number or numbers separated by a space for ${yellow}GeoSite${reset}"
        echo 

        [ "$has_missing_geosite_bases" = true ] && echo "1. Install missing GeoSite" || echo -e "1. ${italic}All available GeoSites installed${reset}"
        [ "$has_updatable_geosite_bases" = true ] && echo "2. Update installed GeoSite" || echo -e "2. ${italic}No GeoSite available for update${reset}"

        [ "$update_refilter_geosite_msg" = "true" ] && refilter_choice="Update" || refilter_choice="Install"
        [ "$update_v2fly_geosite_msg" = "true" ] && v2fly_choice="Update" || v2fly_choice="Install"
        [ "$update_zkeen_geosite_msg" = "true" ] && zkeen_choice="Update" || zkeen_choice="Install"

        echo "     3. $refilter_choice Re:filter"
        echo "     4. $v2fly_choice v2fly"
        echo "     5. $zkeen_choice ZKeen"
        echo 
        echo "0. Skip"

        [ "$has_updatable_geosite_bases" = true ] && echo && echo "6. Remove installed GeoSite"

        echo
        valid_input=true
        
        while true; do
            read -r -p "Your choice:" geosite_choices
            geosite_choices=$(echo "$geosite_choices" | sed 's/,/, /g')

            if echo "$geosite_choices" | grep -qE '^[0-6 ]+$'; then
                break
            else
                echo -e "${red}Invalid input.${reset} Please select again"
            fi
        done

        for choice in $geosite_choices; do
            case "$choice" in
                1)
                    if [ "$has_missing_geosite_bases" = "false" ]; then
                        echo -e "All GeoSites ${green}are already installed${reset}"
                        if input_concordance_list "Do you want to update them?"; then
                            update_refilter_geosite=true
                            update_v2fly_geosite=true
                            update_zkeen_geosite=true
                        else
                            invalid_choice=true
                        fi
                    else
                        [ "$update_refilter_geosite_msg" != "true" ] && install_refilter_geosite=true
                        [ "$update_v2fly_geosite_msg" != "true" ] && install_v2fly_geosite=true
                        [ "$update_zkeen_geosite_msg" != "true" ] && install_zkeen_geosite=true
                    fi
                    ;;
                2)
                    if [ "$has_updatable_geosite_bases" = "false" ]; then
                        echo -e "${red}No GeoSite${reset} installed for update"
                        if input_concordance_list "Do you want to install them?"; then
                            install_refilter_geosite=true
                            install_v2fly_geosite=true
                            install_zkeen_geosite=true
                        else
                            invalid_choice=true
                        fi
                    else
                        [ "$update_refilter_geosite_msg" = "true" ] && update_refilter_geosite=true
                        [ "$update_v2fly_geosite_msg" = "true" ] && update_v2fly_geosite=true
                        [ "$update_zkeen_geosite_msg" = "true" ] && update_zkeen_geosite=true
                    fi
                    ;;
                3)
                    [ "$update_refilter_geosite_msg" != "true" ] && install_refilter_geosite=true || update_refilter_geosite=true
                    ;;
                4)
                    [ "$update_v2fly_geosite_msg" != "true" ] && install_v2fly_geosite=true || update_v2fly_geosite=true
                    ;;
                5)
                    [ "$update_zkeen_geosite_msg" != "true" ] && install_zkeen_geosite=true || update_zkeen_geosite=true
                    ;;
                0)
                    echo "GeoSite installation/update skipped"
                    return
                    ;;
                6)
                    if [ "$has_updatable_geosite_bases" = "false" ]; then
                        echo -e "${red}No GeoSite installed to remove${reset}. Select another item"
                        invalid_choice=true
                    else
                        choice_delete_geosite_refilter_select=true
                        choice_delete_geosite_v2fly_select=true
                        choice_delete_geosite_zkeen_select=true
                    fi
                    ;;
                *)
                    echo -e "${red}Invalid input.${reset} Please select again"
                    invalid_choice=true
                    ;;
            esac
        done

        [ "$invalid_choice" = true ] && continue

        install_list=
        update_list=
        delete_list=

        [ "$install_refilter_geosite" = true ] && install_list="$install_list ${yellow}Re:filter${reset},"
        [ "$install_v2fly_geosite" = true ] && install_list="$install_list ${yellow}v2fly${reset},"
        [ "$install_zkeen_geosite" = true ] && install_list="$install_list ${yellow}ZKeen${reset},"
        [ "$update_refilter_geosite" = true ] && update_list="$update_list ${yellow}Re:filter${reset},"
        [ "$update_v2fly_geosite" = true ] && update_list="$update_list ${yellow}v2fly${reset},"
        [ "$update_zkeen_geosite" = true ] && update_list="$update_list ${yellow}ZKeen${reset},"
        [ "$choice_delete_geosite_refilter_select" = true ] && delete_list="$delete_list ${yellow}Re:filter${reset},"
        [ "$choice_delete_geosite_v2fly_select" = true ] && delete_list="$delete_list ${yellow}v2fly${reset},"
        [ "$choice_delete_geosite_zkeen_select" = true ] && delete_list="$delete_list ${yellow}ZKeen${reset},"

        if [ -n "$install_list" ]; then
            echo -e "The following GeoSites are installed: ${install_list%,}"
        fi

        if [ -n "$update_list" ]; then
            echo -e "The following GeoSites are updated: ${update_list%,}"
        fi

        if [ -n "$delete_list" ]; then
            echo -e "The following GeoSites are deleted: ${delete_list%,}"
        fi

        break
    done
}