# Loading Xray
download_xray() {
    while true; do
        printf "${green}Request information${reset} about releases ${yellow}Xray${reset}\n"
        
        # Getting a list of releases via GitHub API
        RELEASE_TAGS=$(curl --connect-timeout 10 $curl_timeout -s "${xray_api_url}?per_page=20" 2>/dev/null | jq -r '.[] | select(.prerelease == false) | .tag_name' | head -n 8)
        
        if [ -z "$RELEASE_TAGS" ]; then
            echo
            printf "${red}No access${reset} to ${yellow}GitHub API${reset}. Let's try ${yellow}jsDelivr${reset}...\n"
            
            # Getting a list of releases via jsDelivr
            RELEASE_TAGS=$(curl --connect-timeout 10 $curl_timeout -s "$xray_jsd_url" 2>/dev/null | jq -r '.versions[]' | head -n 8)
            
            if [ -z "$RELEASE_TAGS" ]; then
                echo
                printf "${red}No access${reset} to ${yellow}jsDelivr${reset}\n"
                echo
                printf "  ${red}Ошибка${reset}: Не удалось получить список релизов ни через ${yellow}GitHub API${reset}, ни через ${yellow}jsDelivr${reset}\n  Проверьте соединение с интернетом или повторите позже\n  Если ошибка сохраняется, воспользуйтесь возможностью OffLine установки:\n  https://github.com/jameszeroX/XKeen/blob/main/OffLine_install.md\n"
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

        case "$choice" in
            [0-9]) ;;
            *) 
                printf "${red}Invalid ${reset} input. Please enter a number\n"
                sleep 1
                continue
                ;;
        esac

        if [ "$choice" = "0" ]; then
            bypass_xray="true"
            printf "Xray loading ${yellow}skipped${reset}\n"
            return
        fi

        if [ "$choice" = "9" ]; then
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
            version_selected=$(echo "$RELEASE_TAGS" | awk -v line="$choice" 'NR == line {print $0; exit}')
            if [ -z "$version_selected" ]; then
                printf "Selected number ${red}out of range.${reset} Please try again\n"
                sleep 1
                continue
            fi
            if [ "$USE_JSDELIVR" = "true" ]; then
                version_selected="v$version_selected"
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
            *) download_url= ;;
        esac

        if [ -z "$download_url" ]; then
            printf "${red}Error${reset}: Could not get Xray download URL\n"
            exit 1
        fi

        filename=$(basename "$download_url")
        extension="${filename##*.}"
        xray_dist=$(mktemp)
        mkdir -p "$xtmp_dir"

        if [ "$use_direct" != "true" ]; then
            download_url="$gh_proxy/$download_url"
        fi

        printf "${yellow}Check${reset} version availability $version_selected...\n"

        check_url_availability() {
            url=$1
            timeout=$2

            http_status=$(curl --connect-timeout "$timeout" $curl_timeout \
                              -I \
                              -s \
                              -L \
                              -w "%{http_code}" \
                              -o /dev/null \
                              "$url" 2>/dev/null)
            curl_exit_code=$?

            if [ "$curl_exit_code" -eq 0 ] && [ "$http_status" = "405" ]; then
                http_status=$(curl --connect-timeout "$timeout" $curl_timeout \
                                  -s \
                                  -L \
                                  -r 0-0 \
                                  -w "%{http_code}" \
                                  -o /dev/null \
                                  "$url" 2>/dev/null)
                curl_exit_code=$?
            fi

            if [ "$curl_exit_code" -eq 28 ]; then
                printf "${red}Timeout${reset} during check\n"
                return 1
            elif [ "$curl_exit_code" -ne 0 ]; then
                printf "${red}Curl error ($curl_exit_code)${reset} while checking\n"
                return 1
            fi

            case "$http_status" in
                2[0-9][0-9])
                    printf "File ${green}available${reset}\n"
                    return 0
                    ;;
                404)
                    printf "File ${red}not found${reset} (404)\n"
                    return 2
                    ;;
                403)
                    printf "${red}Access denied${reset} (403)\n"
                    return 2
                    ;;
                000)
                    printf "${red}No connection${reset}\n"
                    return 1
                    ;;
                *)
                    printf "  ${yellow}Проблема с доступом${reset} (HTTP: $http_status)\n"
                    return 1
                    ;;
            esac
        }

        # Checking version availability
        if ! check_url_availability "$download_url" 10; then
            rm -f "$xray_dist"
            printf "${red}Error${reset}: Version $version_selected is not available\n"
            continue
        fi

        printf "${yellow}Loading${reset} selected Xray version\n"

        # Loading Xray
        if curl --connect-timeout 10 $curl_timeout \
               -fL \
               -o "$xray_dist" \
               "$download_url" 2>/dev/null; then

            if [ -s "$xray_dist" ]; then
                if head -c 100 "$xray_dist" 2>/dev/null | grep -iq "<!DOCTYPE html\|<html\|Error\|404\|Not Found"; then
                    rm -f "$xray_dist"
                    printf "${red}Error${reset}: Received HTML error page instead of file\n"
                    continue
                fi

                mv "$xray_dist" "$xtmp_dir/xray.$extension"
                printf "Xray ${green}successfully loaded${reset}\n"
                return 0
            else
                rm -f "$xray_dist"
                printf "${red}Error${reset}: The downloaded Xray file is corrupt\n"
                continue
            fi
        else
            rm -f "$xray_dist"
            printf "${red}Error${reset}: Failed to load Xray $version_selected\n"
            continue
        fi
    done
}