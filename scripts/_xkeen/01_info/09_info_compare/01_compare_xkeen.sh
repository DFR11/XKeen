# Function to compare XKeen versions
info_compare_xkeen() {
    if [ "$xkeen_current_version" = "$xkeen_github_version" ]; then
        info_compare_xkeen="actual"
    else
        info_compare_xkeen="update"
    fi
}
