# Registration xray
register_xray_control() {

    # Creating the xray_s.control file
    cat << EOF > "$register_dir/xray_s.control"
Package: xray_s
Version: $xray_current_version
Depends: libc, libssp, librt, libpthread, ca-bundle
Source: XTLS Team
SourceName: xray_s
Section: net
SourceDateEpoch: $source_date_epoch
Maintainer: Skrill / jameszero
Architecture: $status_architecture
Installed-Size: $installed_size
Description: A unified platform for anti-censorship.
EOF
}

register_xray_list() {
    cd "$register_dir/" || exit
    touch xray_s.list

# Generating a list of files
    find /opt/etc/xray/dat -maxdepth 1 -name "*.dat" -type f | while read -r file; do
        echo "$file" >> xray_s.list
    done

    find /opt/etc/xray/configs -maxdepth 1 -name "*.json" -type f | while read -r file; do
        echo "$file" >> xray_s.list
    done

    find /opt/var/log/xray -maxdepth 1 -name "*.log" -type f | while read -r file; do
        echo "$file" >> xray_s.list
    done

    # Adding Additional Paths
    echo "/opt/var/log/xray" >> xray_s.list
    echo "/opt/etc/xray/configs" >> xray_s.list
    echo "/opt/etc/xray/dat" >> xray_s.list
    echo "/opt/etc/xray" >> xray_s.list
    echo "/opt/sbin/xray" >> xray_s.list
}

register_xray_status() {
    # Generating a new entry
    echo "Package: xray_s" > new_entry.txt
    echo "Version: $xray_current_version" >> new_entry.txt
    echo "Depends: libc, libssp, librt, libpthread, ca-bundle" >> new_entry.txt
    echo "Status: install user installed" >> new_entry.txt
    echo "Architecture: $status_architecture" >> new_entry.txt
    echo "Installed-Time: $(date +%s)" >> new_entry.txt

    # Reading the existing contents of the "status" file
    existing_content=$(cat "$status_file")

    # Merging existing content and new entry
    echo "" >> "$status_file"
    cat new_entry.txt >> "$status_file"
    echo "" >> "$status_file"
    sed -i '/^$/{N;/^\n$/D}' "$status_file"
}