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

# Function for entering only numeric characters
input_digits() {
    prompt_message="${1:-Enter numbers: }"
    error_message="${2:-${red}Invalid input.${reset} Literal expressions are not accepted, ${yellow}use numbers${reset}.}"

    while true; do
        read -r -p "  $prompt_message" input
        input=$(echo "$input" | sed 's/,/, /g')
        if echo "$input" | grep -qE '^[0-9 ]+$'; then
            echo "$input"
            return 0
        else
            echo -e "  $error_message"
        fi
    done
}
