# Loading Xray
download_xray() {
    while true; do
        printf "${green}Request information${reset} about releases ${yellow}Xray${reset}\n"
        RELEASE_TAGS=$(curl -m 10 -s ${xray_api_url}?per_page=20 | jq -r '.[] | select(.prerelease == false) | .tag_name' | head -n 8) >/dev/null 2>&1

        if [ -z "$RELEASE_TAGS" ]; then
            echo
            printf "${red}No access${reset} to ${yellow}GitHub API${reset}. Let's try ${yellow}jsDelivr${reset}...\n"
            RELEASE_TAGS=$(curl -m 10 -s $xray_jsd_url | jq -r '.versions[]' | head -n 8) >/dev/null 2>&1
            
            if [ -z "$RELEASE_TAGS" ]; then
                echo
                printf "${red}No access${reset} to ${yellow}jsDelivr${reset}\n"
                echo
                printf "${red}Error${reset}: Could not get list of releases through either ${yellow}GitHub API${reset} or ${yellow}jsDelivr${reset}\n Check your internet connection or try again later\n If the error persists, use the OffLine installation option:\n https://github.com/jameszeroX/XKeen/blob/main/OffLine_install.md\n"
                echo
                exit 1
            fi
            echo
            printf "List of releases obtained using ${yellow}jsDelivr${reset}:\n"
            USE_JSDELIVR="true"
        else
            echo
            printf "List of releases retrieved using ${yellow}GitHub API${reset}:\n"
        fi

        echo
        echo "$RELEASE_TAGS" | awk '{printf "    %2d. %s\n", NR, $0}'
        echo
        echo "9. Manual version entry"
        echo
        echo "0. Skip Xray download"

        printf "\nEnter the release serial number (0 - skip, 9 - manual entry):"
        read -r choice

        if ! echo "$choice" | grep -Eq '^[0-9]$'; then
            printf "${red}Invalid${reset} input. Please enter a number\n"
            sleep 1
            continue
        fi

        if [ "$choice" -eq 0 ]; then
            bypass_xray="true"
            printf "Xray loading ${yellow}skipped${reset}\n"
            return
        fi

        if [ "$choice" -eq 9 ]; then
            printf "Enter the Xray version to download (for example: v25.4.30):"
            read -r version_selected
            if [ -z "$version_selected" ]; then
                printf "${red}Error${reset}: Version cannot be empty\n"
                sleep 1
                continue
            fi

            version_selected=$(echo "$version_selected" | sed 's/^v//')
            version_selected="v$version_selected"

        else
            version_selected=$(echo "$RELEASE_TAGS" | sed -n "${choice}p")
            if [ -z "$version_selected" ]; then
                printf "Selected number ${red}out of range.${reset} Please try again\n"
                sleep 1
                continue
            fi
        fi

        if [ -z "$USE_JSDELIVR" ]; then
            VERSION_ARG="$version_selected"
        else
            VERSION_ARG="$version_selected"
            unset USE_JSDELIVR
        fi

        URL_BASE="${xray_zip_url}/$VERSION_ARG"

        case $architecture in
            "arm64-v8a") download_url="$URL_BASE/Xray-linux-arm64-v8a.zip" ;;
            "mips32le") download_url="$URL_BASE/Xray-linux-mips32le.zip" ;;
            "mips32") download_url="$URL_BASE/Xray-linux-mips32.zip" ;;
            "mips64") download_url="$URL_BASE/Xray-linux-mips64.zip" ;;
            "mips64le") download_url="$URL_BASE/Xray-linux-mips64le.zip" ;;
            "arm32-v5") download_url="$URL_BASE/Xray-linux-arm32-v5.zip" ;;
            *) download_url= ;;
        esac

        if [ -z "$download_url" ]; then
            echo -e "${red}Error${reset}: Could not get Xray download URL"
            exit 1
        fi

        filename=$(basename "$download_url")
        extension="${filename##*.}"
        xray_dist=$(mktemp)
        mkdir -p "$xtmp_dir"
        
        echo -e "${yellow}Checking${reset} version availability $version_selected..."
        
        # Function to check availability
        check_url_availability() {
            local url=$1
            local timeout=$2
            local description=$3

            echo -e "${yellow}Check via $description...${reset}"
            http_status=$(curl -m $timeout -L -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
            curl_exit_code=$?

            if [ $curl_exit_code -eq 28 ]; then
                echo -e "${red}Timeout${reset} when checking via $description"
                return 1
            elif [ $curl_exit_code -ne 0 ]; then
                echo -e "${red}Curl error ($curl_exit_code)${reset} when checking via $description"
                return 1
            elif [ "$http_status" -eq 200 ]; then
                echo -e "${green} version available via $description${reset}"
                return 0
            elif [ "$http_status" -eq 404 ]; then
                echo -e "${red}Version not found${reset} via $description (404)"
                return 2
            else
                echo -e "${yellow}Problem accessing ${reset} via $description (HTTP: $http_status)"
                return 1
            fi
        }

        # Checking version availability
        if [ -z "$USE_JSDELIVR" ]; then
            if check_url_availability "$download_url" 10 "GitHub"; then
                USE_DIRECT="true"
            else
                echo -e "${yellow}Trying to check through a proxy...${reset}"
                if check_url_availability "$gh_proxy/$download_url" 10 "proxy"; then
                    USE_PROXY="true"
                else
                    echo -e "${red}Error${reset}: Version $version_selected is not available either directly or via proxy"
                    echo -e "Possible reasons:"
                    echo -e "- Version $version_selected does not exist"
                    echo -e "- $architecture is not supported"
                    echo -e "- Network problems"
                    rm -f "$xray_dist"
                    sleep 2
                    continue
                fi
            fi
        else
            if ! check_url_availability "$download_url" 10 "jsDelivr"; then
                echo -e "${red}Error${reset}: Version $version_selected is not available via jsDelivr"
                rm -f "$xray_dist"
                sleep 2
                continue
            fi
            USE_DIRECT="true"
        fi

        # Function to download
        download_with_retry() {
            local url=$1
            local description=$2
            local max_attempts=2

            for attempt in $(seq 1 $max_attempts); do
                echo -e "${yellow}Attempting to load $attempt/$max_attempts via $description...${reset}"

                if curl -m 10 -L -o "$xray_dist" "$url" 2>/dev/null; then
                    if [ -s "$xray_dist" ]; then
                        echo -e "Xray ${green} loaded successfully via $description${reset}"
                        return 0
                    else
                        echo -e "${red}Error${reset}: The downloaded Xray file is corrupt (empty)"
                        rm -f "$xray_dist"
                        xray_dist=$(mktemp)
                    fi
                else
                    echo -e "${red}Loading error${reset} via $description (trying $attempt/$max_attempts)"
                fi
                
                if [ $attempt -lt $max_attempts ]; then
                    echo -e "${yellow}Try again in 2 seconds...${reset}"
                    sleep 2
                fi
            done
            return 1
        }

        echo -e "${yellow}Loading${reset} selected Xray version"
        
        if [ "$USE_PROXY" = "true" ]; then
            if download_with_retry "$gh_proxy/$download_url" "proxy"; then
                mv "$xray_dist" "$xtmp_dir/xray.$extension"
                unset USE_PROXY
                return 0
            fi
        else
            if download_with_retry "$download_url" "direct connection"; then
                mv "$xray_dist" "$xtmp_dir/xray.$extension"
                return 0
            else
                echo -e "${yellow}Trying to download through a proxy...${reset}"
                if download_with_retry "$gh_proxy/$download_url" "proxy"; then
                    mv "$xray_dist" "$xtmp_dir/xray.$extension"
                    return 0
                fi
            fi
        fi
        
        # If all download attempts fail
        rm -f "$xray_dist"
        echo -e "${red}Error${reset}: Failed to load Xray after all attempts. Check:"
        echo -e "- Existence of $version_selected version"
        echo -e "- $architecture support"
        echo -e "- Internet connection"
        echo -e "${yellow}Please try another version${reset}"
        sleep 2
        continue
    done
}