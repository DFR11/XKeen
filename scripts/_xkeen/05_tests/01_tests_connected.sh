tests_connection() {
    result=1
    
    # Checking connection to google.com
    if ping -c 4 google.com > /dev/null 2>&1; then
        result=0
    else
        echo -e "${red}Error${reset}: google.com does not respond to ping"
    fi

    # Checking connection to yandex.ru
    if ping -c 4 yandex.ru > /dev/null 2>&1; then
        result=0
    else
        echo -e "${red}Error${reset}: yandex.ru does not respond to ping"
    fi

    # We check the function completion code and display a message
    if [ $result -eq 0 ]; then
        echo -e "Internet connection ${green}working${reset}"
    else
        echo -e "${red}Missing${reset} internet connection"
    fi
	
    return 1
}
