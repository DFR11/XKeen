# Importing core modules and defining their paths

script_dir="$(cd "$(dirname "$0")" && pwd)"
xinfo_dir="$script_dir/.xkeen/01_info"
xinstall_dir="$script_dir/.xkeen/02_install"
xdelete_dir="$script_dir/.xkeen/03_delete"
xtools_dir="$script_dir/.xkeen/04_tools"
xtests_dir="$script_dir/.xkeen/05_tests"
main_dir="$script_dir/.xkeen"

# Information module
. "$xinfo_dir/00_info_import.sh"

# Installation module
. "$xinstall_dir/00_install_import.sh"

# Removal module
. "$xdelete_dir/00_delete_import.sh"

# Toolkit module
. "$xtools_dir/00_tools_import.sh"

# Test module
. "$xtests_dir/00_tests_import.sh"

# Help module
. "$main_dir/about.sh"