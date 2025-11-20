data_is_updated_exclude() {
    file="$1"
    new_delay="$2"
    current_delay=$(
        awk -F= '/start_delay/{print $2; exit}' "$file" \
        | tr -d '"'
    )
    if [ "$current_delay" = "$new_delay" ]; then
        return 0
    else
        return 1
    fi
}

delay_autostart() {
    new_delay="$1"
    target_file=""

    if [ -f "$initd_dir/S99xkeen" ]; then
        target_file="$initd_dir/S99xkeen"
    else
        echo -e "${red}Error${reset}: S99xkeen startup file not found"
        return 1
    fi

    # Displays the current autostart delay
    if [ -z "$new_delay" ]; then
        current_delay=$(
            awk -F= '/start_delay/{print $2; exit}' "$target_file" \
            | tr -d '[:space:]'
        )
        current_delay=${current_delay:-""}
        echo -e "Current XKeen autorun delay ${yellow}$current_delay seconds(s)${reset}"
        return 1
    fi

    # Checking that new_delay is a number
    if ! [ "$new_delay" -eq "$new_delay" ] 2>/dev/null; then
        echo -e "${red}Error${reset}"
        echo "The new delay must be a number"
        return 1
    fi

    current_delay=$(
        awk -F= '/start_delay/{print $2; exit}' "$target_file" \
        | tr -d '[:space:]'
    )
    current_delay=${current_delay:-""}

    if [ "$current_delay" = "$new_delay" ]; then
        echo "XKeen autostart delay update is not required"
        return 0
    else
        tmpfile=$(mktemp)
        awk -v new_delay="start_delay=$new_delay" 'BEGIN{replaced=0} /start_delay/ && !replaced {sub(/start_delay=[^ ]*/, new_delay); replaced=1} {print}' "$target_file" > "$tmpfile" && mv "$tmpfile" "$target_file"
    fi

    while true; do
        if data_is_updated_exclude "$target_file" "$new_delay"; then
            echo -e "${green}Success${reset}"
            echo -e "XKeen autorun delay set ${yellow}${new_delay} seconds(s)${reset}"
            break
        fi
    done
}