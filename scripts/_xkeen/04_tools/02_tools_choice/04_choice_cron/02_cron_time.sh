# Timing cron jobs

choice_cron_time() {
    for task in all geofile xkeen xray; do
        task_var="choice_${task}_cron_select"
        time_var="choice_${task}_cron_time"

        if [ "$(eval echo \${$task_var})" = true ]; then
            echo
            if [ "$task" = "all" ]; then
                echo -e "Automatic update time for ${yellow}all${reset} tasks:"
            else
                echo -e "Automatic update time ${yellow}$task${reset}:"
            fi
            echo
            echo "Select day"
            echo "0. Cancel"
            echo "1. Monday"
            echo "2. Tuesday"
            echo "3. Environment"
            echo "4. Thursday"
            echo "5. Friday"
            echo "6. Saturday"
            echo "7. Sunday"
            echo "8. Daily"
            echo

            day_choice=
            while true; do
                read -r -p "Your choice:" day_choice
                if echo "$day_choice" | grep -qE '^[0-8]$'; then
                    break
                else
                    echo -e "${red}Invalid action number.${reset} Please select again"
                fi
            done

            if [ "$day_choice" -eq 0 ]; then
                echo -e "Automatic update ${yellow}$task${reset} has been disabled."
            else
                if [ "$day_choice" -eq 8 ]; then
                    echo
                    read -r -p "Select hour (0-23):" hour
                        while ! { case "$hour" in *[!0-9]*) false;; *) [ "$hour" -ge 0 ] && [ "$hour" -le 23 ];; esac; }; do
                        echo -e "${red}Incorrect hour.${reset} Please try again"
                        read -r -p "Enter a value from 0 to 23:" hour
                    done

                    read -r -p "Select minute (0-59):" minute
                    while ! { case "$minute" in *[!0-9]*) false;; *) [ "$minute" -ge 0 ] && [ "$minute" -le 59 ];; esac; }; do
                        echo -e "${red}Incorrect minutes.${reset} Please try again"
                        read -r -p "Enter a value from 0 to 59:" minute
                    done

                    cron_expression="$minute $hour * * *"
                    cron_display="$minute $hour * * *"
                else
                    echo
                    read -r -p "Select hour (0-23):" hour
                    while ! { case "$hour" in *[!0-9]*) false;; *) [ "$hour" -ge 0 ] && [ "$hour" -le 23 ];; esac; }; do
                        echo -e "${red}Incorrect hour.${reset} Please try again"
                        read -r -p "Enter a value from 0 to 23:" hour
                    done

                    read -r -p "Select minute (0-59):" minute
                    while ! { case "$minute" in *[!0-9]*) false;; *) [ "$minute" -ge 0 ] && [ "$minute" -le 59 ];; esac; }; do
                        echo -e "${red}Incorrect minutes.${reset} Please try again"
                        read -r -p "Enter a value from 0 to 59:" minute
                    done

                    case "$day_choice" in
                        1) day_of_week="1" ;;
                        2) day_of_week="2" ;;
                        3) day_of_week="3" ;;
                        4) day_of_week="4" ;;
                        5) day_of_week="5" ;;
                        6) day_of_week="6" ;;
                        7) day_of_week="0" ;;
                    esac

                    cron_expression="$minute $hour * * $day_of_week"
                    cron_display="$minute $hour * * $day_of_week"
                fi

                formatted_hour=$(printf "%02d" "$hour")
                formatted_minute=$(printf "%02d" "$minute")

                day_name=
                case "$day_choice" in
                    0) day_name="Cancel" ;;
                    1) day_name="Monday" ;;
                    2) day_name="Tuesday" ;;
                    3) day_name="Wednesday" ;;
                    4) day_name="Thursday" ;;
                    5) day_name="Friday" ;;
                    6) day_name="Saturday" ;;
                    7) day_name="Sunday" ;;
                    8) day_name="Daily" ;;
                esac

                if [ "$task" = "all" ]; then
                    echo
                    echo -e "Selected auto update time for ${yellow}all${reset} tasks: $day_name in $formatted_hour:$formatted_minute"
                else
                    echo
                    echo -e "Selected auto update time ${yellow}$task${reset}: $day_name in $formatted_hour:$formatted_minute"
                fi

                eval "${time_var}='$cron_expression'"
            fi
        fi
    done
}
