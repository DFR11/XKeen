# Function for user selection between "Yes" and "No" with numbers 0 and 1
input_concordance_list() {
    prompt_message="  $1"
    error_message="${yellow}Please select an option by entering the number 0 (No) or 1 (Yes)${reset}"

    echo
    echo -e "$prompt_message"
    echo "0. No"
    echo "1. Yes"

    while true; do
        echo
        read -r -p "Enter number:" user_input

        case "$user_input" in
            0) return 1 ;;
            1) return 0 ;;
            *)
                echo
                echo -e "  $error_message"
                continue
                ;;
        esac
    done
}

toggle_param() {
    param="$1"
    description="$2"
    restart_needed="$3"

    if [ ! -f "$initd_file" ]; then
        echo -e "${red}Error${reset}: File not found ${yellow}S99xkeen${reset}"
        return 1
    fi

    current_state=$(grep -m 1 -E "^[[:space:]]*$param=" "$initd_file" | cut -d'=' -f2 | tr -d '"[:space:]')

    echo
    echo -e "Current state of ${description}:"

    if [ "$current_state" = "on" ]; then
        echo -e "${green}Enabled${reset}"
        echo
        echo "1. Disable"
        echo "0. Leave unchanged"
        desired_state="off"
    else
        echo -e "${red}Disabled${reset}"
        echo
        echo "1. Enable"
        echo "0. Leave unchanged"
        desired_state="on"
    fi

    echo
    while true; do
        read -r -p "Your choice:" choice
        case "$choice" in
            0)
                return 0
                ;;
            1)
                break
                ;;
            *)
                echo -e "${red}Invalid input${reset}"
                ;;
        esac
    done

    if awk -v param="$param" -v value="$desired_state" '
        !found && $0 ~ "^[[:space:]]*" param "=" {
            sub(/"[^"]*"/, "\"" value "\"")
            found=1
        }
        {print}
        ' "$initd_file" > "$initd_file.tmp" && mv "$initd_file.tmp" "$initd_file"; then
        if [ "$desired_state" = "on" ]; then
            echo -e "New state ${description} ${green}enabled${reset}"
        else
            echo -e "New state ${description} ${red}disabled${reset}"
        fi

        if [ "$restart_needed" = "reboot" ]; then
            echo
            echo -e "${yellow}Reboot your router to apply the changes${reset}"
        elif [ "$restart_needed" = "restart" ]; then
            echo
            echo -e "${yellow}Restart XKeen to apply changes${reset}"
        fi

        add_chmod_init
    else
        echo -e "${red}Error${reset} when changing parameter $param"
        return 1
    fi
}

choice_menu() {
    title="$1"
    option_yes="$2"
    option_no="$3"

    echo
    [ -n "$title" ] && echo -e "  $title"
    echo
    echo "     1. $option_yes"
    echo "     0. $option_no"
    echo

    while true; do
        read -r -p "Your choice:" choice
        case "$choice" in
            1) return 0 ;;
            0) return 1 ;;
            *) echo -e "${red}Invalid input${reset}" ;;
        esac
    done
}