# Function to check the presence of required packages
info_packages() {
    package_name="$1"
    
    # Checking if the package is installed
    if opkg list-installed | grep -q "$package_name"; then
        package_status="installed"
    else
        package_status="not_installed"
    fi
}

# Checking for the presence of the "lscpu" package
info_packages "lscpu"
info_packages_lscpu=$package_status

# Checking for package "coreutils-uname"
info_packages "coreutils-uname"
info_packages_uname=$package_status

# Checking for package "coreutils-nohup"
info_packages "coreutils-nohup"
info_packages_nohup=$package_status

# Checking for package "curl"
info_packages "curl"
info_packages_curl=$package_status

# Checking for package "jq"
info_packages "jq"
info_packages_jq=$package_status

# Checking for package "libc"
info_packages "libc"
info_packages_libc=$package_status

# Checking for package "libssp"
info_packages "libssp"
info_packages_libssp=$package_status

# Checking for package "librt"
info_packages "librt"
info_packages_librt=$package_status

# Checking for package "libpthread"
info_packages "libpthread"
info_packages_libpthread=$package_status

# Checking for the presence of the "ca-bundle" package
info_packages "ca-bundle"
info_packages_cabundle=$package_status

# Checking for the presence of the "iptables" package
info_packages "iptables"
info_packages_iptables=$package_status