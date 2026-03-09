read_ports_file() {
    file="$1"

    [ -f "$file" ] || return

    sed 's/\r$//' "$file" | \
    sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
    grep -v '^#' | \
    grep -v '^$' | \
    sed 's/-/:/g' | \
    grep -E '^[0-9]+(:[0-9]+)?$' | \
    tr '\n' ',' | \
    sed 's/,$//'
}

write_ports_file() {
    file="$1"
    ports="$2"

    tmpfile=$(mktemp)

    echo "# XKeen ports list" > "$tmpfile"
    echo "$ports" | tr ',' '\n' >> "$tmpfile"

    mv "$tmpfile" "$file"
}

ports_conflict_check() {
    file1="$1"
    file2="$2"

    ports1=$(read_ports_file "$file1")
    ports2=$(read_ports_file "$file2")

    if [ -n "$ports1" ] && [ -n "$ports2" ]; then
        return 0
    fi

    return 1
}

data_is_updated_donor() {
    file=$1
    new_ports=$2
    current_ports=$(
        awk -F= '/^port_donor/{print $2; exit}' "$file" \
        | tr -d '"'
    )
    if [ "$current_ports" = "$new_ports" ]; then
        return 0
    else
        return 1
    fi
}

data_is_updated_excluded() {
    file=$1
    new_ports=$2
    current_ports=$(
        awk -F= '/^port_exclude/{print $2; exit}' "$file" \
        | tr -d '"'
    )
    if [ "$current_ports" = "$new_ports" ]; then
        return 0
    else
        return 1
    fi
}

normalize_ports() {
    echo "$1" | tr ',' '\n' | awk '
    function valid(p) {
        return (p ~ /^[0-9]+$/ && p >= 0 && p <= 65535)
    }

    {
        gsub(/[[:space:]]/, "")
        if ($0 == "") next

        gsub(/-/, ":")

        n = split($0, a, ":")

        if (n == 1) {
            if (valid(a[1])) ports[a[1]]
        }

        else if (n == 2) {
            if (valid(a[1]) && valid(a[2])) {
                start = a[1]
                end   = a[2]

                if (start > end) {
                    tmp = start
                    start = end
                    end = tmp
                }

                ports[start ":" end]
            }
        }
    }

    END {
        for (p in ports)
            print p
    }
    ' | sort -n | tr '\n' ',' | sed 's/,$//'
}

ensure_web_ports() {
    ports="$1"

    echo "$ports" | tr ',' '\n' | grep -qx "80"  || ports="$ports,80"
    echo "$ports" | tr ',' '\n' | grep -qx "443" || ports="$ports,443"

    normalize_ports "$ports"
}

# Custom Port Processing Function
process_user_ports() {
    user_proxy_ports=""
    user_exclude_ports=""

    if [ -f "$file_port_proxying" ]; then
        user_proxy_ports=$(
            sed 's/\r$//' "$file_port_proxying" | \
            sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
            grep -v '^#' | \
            grep -v '^$' | \
            sed 's/-/:/g' | \
            grep -E '^[0-9]+(:[0-9]+)?$' | \
            tr '\n' ',' | \
            sed 's/,$//'
        )
    fi

    if [ -f "$file_port_exclude" ]; then
        user_exclude_ports=$(
            sed 's/\r$//' "$file_port_exclude" | \
            sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
            grep -v '^#' | \
            grep -v '^$' | \
            sed 's/-/:/g' | \
            grep -E '^[0-9]+(:[0-9]+)?$' | \
            tr '\n' ',' | \
            sed 's/,$//'
        )
    fi

    if [ -n "$user_proxy_ports" ]; then
        port_donor="${port_donor},${user_proxy_ports}"
    elif [ -n "$user_exclude_ports" ]; then
        port_exclude="${port_exclude},${user_exclude_ports}"
    else
        :
    fi
}

add_ports_donor() {
    [ -z "$1" ] && {
        echo -e "${red}Error${reset}: port list cannot be empty"
        return 1
    }

    # conflict
    if ports_conflict_check "$file_port_proxying" "$file_port_exclude"; then
        echo -e "${red}Error${reset}: excluded ports already specified"
        return 1
    fi

    new_ports=$(normalize_ports "$1")
    current_ports=$(read_ports_file "$file_port_proxying")
    current_ports=$(normalize_ports "$current_ports")

    if [ -n "$current_ports" ]; then
        all_ports=$(echo "$current_ports,$new_ports" | tr ',' '\n' | sort -n -u | tr '\n' ',' | sed 's/,$//')
    else
        all_ports="$new_ports"
    fi

    all_ports=$(ensure_web_ports "$all_ports")

    write_ports_file "$file_port_proxying" "$all_ports"

    echo -e "${green}Proxy ports updated${reset}"
}

dell_ports_donor() {
    ports_to_del=$(normalize_ports "$1")
    current_ports=$(read_ports_file "$file_port_proxying")

    [ -z "$current_ports" ] && {
        echo -e "${yellow}File is empty${reset}"
        return
    }

    if [ -z "$ports_to_del" ]; then
        > "$file_port_proxying"
        echo -e "${green}All ports removed${reset}"
        return
    fi

    new_ports="$current_ports"

    for port in $(echo "$ports_to_del" | tr ',' '\n'); do
        new_ports=$(echo "$new_ports" | tr ',' '\n' | grep -vFx "$port" | tr '\n' ',' | sed 's/,$//')
    done

    write_ports_file "$file_port_proxying" "$new_ports"

    echo -e "${green}Ports removed${reset}"
}

add_ports_exclude() {
    [ -z "$1" ] && {
        echo -e "${red}Error${reset}: port list cannot be empty"
        return 1
    }

    if ports_conflict_check "$file_port_proxying" "$file_port_exclude"; then
        echo -e "${red}Error${reset}: proxy ports are already set"
        return 1
    fi

    new_ports=$(normalize_ports "$1")
    current_ports=$(read_ports_file "$file_port_exclude")
    current_ports=$(normalize_ports "$current_ports")

    if [ -n "$current_ports" ]; then
        all_ports=$(echo "$current_ports,$new_ports" | tr ',' '\n' | sort -n -u | tr '\n' ',' | sed 's/,$//')
    else
        all_ports="$new_ports"
    fi

    write_ports_file "$file_port_exclude" "$all_ports"

    echo -e "${green}Exception ports updated${reset}"
}

dell_ports_exclude() {
    ports_to_del=$(normalize_ports "$1")
    current_ports=$(read_ports_file "$file_port_exclude")

    [ -z "$current_ports" ] && {
        echo -e "${yellow}File is empty${reset}"
        return
    }

    if [ -z "$ports_to_del" ]; then
        > "$file_port_exclude"
        echo -e "${green}All exceptions removed${reset}"
        return
    fi

    new_ports="$current_ports"

    for port in $(echo "$ports_to_del" | tr ',' '\n'); do
        new_ports=$(echo "$new_ports" | tr ',' '\n' | grep -vFx "$port" | tr '\n' ',' | sed 's/,$//')
    done

    write_ports_file "$file_port_exclude" "$new_ports"

    echo -e "${green}Exception ports removed${reset}"
}

# Get a list of proxy ports
get_ports_donor() {
    ports=$(read_ports_file "$file_port_proxying")

    if [ -z "$ports" ]; then
        echo -e "Proxy client running ${yellow}on all ports${reset}"
    else
        echo "$ports" | tr ',' '\n' | sed 's/^/     /'
    fi
}

# Get a list of ports excluded from proxying
get_ports_exclude() {
    ports=$(read_ports_file "$file_port_exclude")

    if [ -z "$ports" ]; then
        echo -e "There are no ports excluded from proxying"
    else
        echo "$ports" | tr ',' '\n' | sed 's/^/     /'
    fi
}

migrate_ports_from_initd() {
    [ -f "$initd_file" ] || return

    # Reading old values
    port_donor_val=$(
        awk -F= '/^port_donor=/{print $2; exit}' "$initd_file" | tr -d '"'
    )

    port_exclude_val=$(
        awk -F= '/^port_exclude=/{print $2; exit}' "$initd_file" | tr -d '"'
    )

    port_donor_val=$(normalize_ports "$port_donor_val")
    port_exclude_val=$(normalize_ports "$port_exclude_val")

    migrated=0

    # --- Migration port_donor ---
    if [ -n "$port_donor_val" ]; then

        current_proxy=$(normalize_ports "$(read_ports_file "$file_port_proxying")")

        combined=$(normalize_ports "$current_proxy,$port_donor_val")

        if [ "$combined" != "$current_proxy" ]; then
            tmpfile=$(mktemp)
            echo "# XKeen port proxying list (migrated)" > "$tmpfile"
            echo "$combined" | tr ',' '\n' >> "$tmpfile"
            mv "$tmpfile" "$file_port_proxying"
        fi
    fi

    # --- Migration port_exclude ---
    if [ -n "$port_exclude_val" ]; then

        current_exclude=$(normalize_ports "$(read_ports_file "$file_port_exclude")")

        combined=$(normalize_ports "$current_exclude,$port_exclude_val")

        if [ "$combined" != "$current_exclude" ]; then
            tmpfile=$(mktemp)
            echo "# XKeen port exclude list (migrated)" > "$tmpfile"
            echo "$combined" | tr ',' '\n' >> "$tmpfile"
            mv "$tmpfile" "$file_port_exclude"
        fi
    fi
}