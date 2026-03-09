# Determining status for cron tasks

choice_update_cron() {
    has_updatable_cron_tasks=false
    [ "$info_update_geofile_cron" = "installed" ] && has_updatable_cron_tasks=true

    while true; do
        choice_canel_cron_select=false
        choice_geofile_cron_select=false
        choice_delete_all_cron_select=false
        invalid_choice=false

        echo
        echo -e "${yellow}Select action number${reset} to auto-update GeoFile"
        echo

        [ "$info_update_geofile_cron" != "installed" ] && geofile_choice="Turn on" || geofile_choice="Update"
        echo "1. to the $geofile_choice task"
        echo "0. Skip"

        [ "$has_updatable_cron_tasks" = true ] && echo && echo "2. Turn off auto-update"
        echo

        while true; do
            read -r -p "Your choice:" update_choices
            update_choices=$(echo "$update_choices" | sed 's/,/, /g')

            if echo "$update_choices" | grep -qE '^[0-2]$'; then
                break
            else
                echo -e "${red}Invalid input.${reset} Select one of the suggested options"
            fi
        done

        for choice in $update_choices; do
            case "$choice" in
                1)
                    choice_geofile_cron_select=true
                    if [ "$info_update_geofile_cron" = "installed" ]; then
                        echo -e "${yellow}${reset} will update the GeoFile task"
                    else
                        echo -e "${yellow}${reset} will be performed to enable the GeoFile task"
                    fi
                    ;;
                0)
                    choice_canel_cron_select=true
                    echo "Auto-update setting skipped"
                    return
                    ;;
                2)
                    if [ "$has_updatable_cron_tasks" = true ]; then
                        delete_cron_geofile
                        echo -e "Automatic update of GeoFile databases ${green}disabled${reset}"
                    else
                        echo -e "${red}Auto-update of GeoFile databases is not enabled${reset}. Select another item"
                        invalid_choice=true
                    fi
                    ;;
                *)
                    echo -e "${red}Invalid input${reset}"
                    invalid_choice=true
                    ;;
            esac
        done

        [ "$invalid_choice" = true ] || break
    done
}
