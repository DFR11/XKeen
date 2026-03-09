# Internet availability check function
test_connection() {
    result=1

    if ! ping -c 2 -W 5 "$conn_IP1" >/dev/null 2>&1 && \
       ! ping -c 2 -W 5 "$conn_IP2" >/dev/null 2>&1; then
        result=0
    fi

    if [ "$result" -eq 0 ]; then
        printf "${red}No${reset} internet connection\n"
        exit 1
    fi
}

# Download function
download_with_check() {
    url="$1"
    output_file="$2"
    min_size="${3:-300000}"

    (curl --connect-timeout 10 $curl_timeout -s -L "$url" -o "$output_file" 2>/dev/null) &
    pid=$!

    i=1
    while [ $i -le 10 ]; do
        kill -0 $pid 2>/dev/null 2>/dev/null || break
        sleep 1
        i=$((i + 1))
    done

    if kill -0 $pid 2>/dev/null 2>/dev/null; then
        kill $pid 2>/dev/null
        wait $pid 2>/dev/null
    fi

    if [ -f "$output_file" ]; then
        size=$(wc -c < "$output_file" 2>/dev/null || echo 0)
        if [ "$size" -gt "$min_size" ]; then
            return 0  # Success
        fi
    fi

    rm -f "$output_file" 2>/dev/null
    return 1  # Error
}

# Entware availability check feature
test_entware() {
    printf "${yellow}Checking ${reset} availability of the Entware repository. Please wait...\n"
    repo_url=$(awk '/^src/ {print $3; exit}' /opt/etc/opkg.conf 2>/dev/null)

    if [ -z "$repo_url" ]; then
        printf "${red}Failed${reset} to determine which Entware repository to use\n"
        exit 1
    fi

    repo_url="$repo_url/Packages.gz"
    tmp_file="/tmp/pkg_check_$$"

    if download_with_check "$repo_url" "$tmp_file"; then
        printf "Entware repository ${green}available${reset}. Let's continue...\n"

        opkg update >/dev/null 2>&1
        opkg upgrade >/dev/null 2>&1
        info_packages
        install_packages
        rm -f "$tmp_file" 2>/dev/null
        return 0
    else
        printf "Entware repository ${red}unavailable${reset}\n"
        printf "  Укажите рабочее зеркало репозитория в файле ${yellow}/opt/etc/opkg.conf${reset}\n"
        exit 1
    fi
}

# GitHub Availability Checker Feature
test_github() {
    use_direct="false"
    gh_proxy=""
    tmp_file="/tmp/gh_check_$$"

    printf "${yellow}Check availability${reset} GitHub. Please wait...\n"

    if download_with_check "$zkeenip_url" "$tmp_file"; then
        use_direct="true"
        rm -f "$tmp_file" 2>/dev/null
        printf "GitHub ${green}available${reset}. Let's continue...\n"
        return 0
    fi

    proxied_url="${gh_proxy1}/${zkeenip_url}"
    if download_with_check "$proxied_url" "$tmp_file"; then
        gh_proxy="$gh_proxy1"
        rm -f "$tmp_file" 2>/dev/null
        printf "GitHub ${green}is available via proxy${reset}. Let's continue...\n"
        return 0
    fi

    proxied_url="${gh_proxy2}/${zkeenip_url}"
    if download_with_check "$proxied_url" "$tmp_file"; then
        gh_proxy="$gh_proxy2"
        rm -f "$tmp_file" 2>/dev/null
        printf "GitHub ${green}is available via proxy${reset}. Let's continue...\n"
        return 0
    fi

    printf "${red}Error${reset}: GitHub is unavailable\n"
    exit 1
}