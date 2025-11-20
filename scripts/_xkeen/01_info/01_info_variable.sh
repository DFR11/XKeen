# -------------------------------------
# Colors
# -------------------------------------
green="\033[92m"	# Green
red="\033[91m"		# Red
yellow="\033[33m"	# Yellow
light_blue="\033[96m"	# Blue
italic="\033[3m"	# Italics
reset="\033[0m"		# Reset colors

# -------------------------------------
# Directories
# -------------------------------------
tmp_dir_global="/opt/tmp"		 # General temporary directory
tmp_dir="/opt/tmp/xkeen"		 # XKeen temporary directory
xtmp_dir="/opt/tmp/xray"		 # Xray temporary directory
mtmp_dir="/opt/tmp/mihomo"		 # Mihomo temporary directory
xkeen_dir="/opt/sbin/.xkeen"		 # XKeen script directory
xkeen_cfg="/opt/etc/xkeen"		 # XKeen configurations directory
xkeen_log_dir="/opt/var/log/xkeen"	 # XKeen log directory
xray_log_dir="/opt/var/log/xray"	 # Xray log directory
initd_dir="/opt/etc/init.d"		 # init.d directory
pid_dir="/opt/var/run"			 # Directory pid file
backups_dir="/opt/backups"		 # Backup directory
install_dir="/opt/sbin"			 # Installation directory
geo_dir="/opt/etc/xray/dat"		 # Directory for dat
cron_dir="/opt/var/spool/cron/crontabs"	 # Directory planner
cron_file="root"			 # Scheduler file
install_conf_dir="/opt/etc/xray/configs" # Xray configurations directory
mihomo_conf_dir="/opt/etc/mihomo"	 # Mihomo configuration directory
xkeen_conf_dir="$xkeen_dir/02_install/08_install_configs/02_configs_dir"
xkeen_var_file="$xkeen_dir/01_info/01_info_variable.sh"
register_dir="/opt/lib/opkg/info"
status_file="/opt/lib/opkg/status"
os_modules="/lib/modules/$(uname -r)"
user_modules="/opt/lib/modules"
xkeen_current_version="1.1.3.9"
xkeen_build="Beta"

# -------------------------------------
# Time
# -------------------------------------
existing_content=$(cat "$status_file")
installed_size=$(du -s "$install_dir" | cut -f1)
source_date_epoch=$(date +%s)
current_datetime=$(date "+%d-%b-%y_%H-%M")

# -------------------------------------
# URL
# -------------------------------------
xkeen_api_url="https://api.github.com/repos/jameszeroX/xkeen/releases/latest"			# url api for XKeen
xkeen_jsd_url="https://data.jsdelivr.com/v1/package/gh/jameszeroX/xkeen"			# backup url api for XKeen
xkeen_tar_url="https://github.com/jameszeroX/XKeen/releases/latest/download/xkeen.tar.gz"	# XKeen download url
xkeen_dev_url="https://raw.githubusercontent.com/jameszeroX/xkeen/main/test/xkeen.tar.gz"	# XKeen dev download url
xray_api_url="https://api.github.com/repos/XTLS/Xray-core/releases"				# url api for Xray
xray_jsd_url="https://data.jsdelivr.com/v1/package/gh/XTLS/Xray-core"				# backup url api for Xray
xray_zip_url="https://github.com/XTLS/Xray-core/releases/download"				# Xray download url
mihomo_api_url="https://api.github.com/repos/MetaCubeX/mihomo/releases"				# url api for Mihomo
mihomo_jsd_url="https://data.jsdelivr.com/v1/package/gh/MetaCubeX/mihomo"			# backup url api for Mihomo
mihomo_gz_url="https://github.com/MetaCubeX/mihomo/releases/download"				# Mihomo download url
yq_dist_url="https://github.com/mikefarah/yq/releases/latest/download"				# Yq download url
gh_proxy="https://ghfast.top"									# proxy for downloading (https://ghproxy.link)

# url for downloading geofiles
refilter_url="https://github.com/1andrevich/Re-filter-lists/releases/latest/download/geosite.dat"
refilterip_url="https://github.com/1andrevich/Re-filter-lists/releases/latest/download/geoip.dat"
v2fly_url="https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat"
v2flyip_url="https://github.com/loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
zkeen_url="https://github.com/jameszeroX/zkeen-domains/releases/latest/download/zkeen.dat"
zkeenip_url="https://github.com/jameszeroX/zkeen-ip/releases/latest/download/zkeenip.dat"

# -------------------------------------
# Creating directories and files
# -------------------------------------
mkdir -p "$xray_log_dir" || { echo "Output: No luck to create a director of $xray_log_dir"; exit 1; }
mkdir -p "$initd_dir" || { echo "Error: Failed to create directory $initd_dir"; exit 1; }
mkdir -p "$pid_dir" || { echo "Error: Failed to create directory $pid_dir"; exit 1; }
mkdir -p "$backups_dir" || { echo "Error: Failed to create directory $backups_dir"; exit 1; }
mkdir -p "$install_dir" || { echo "Error: Failed to create directory $install_dir"; exit 1; }
mkdir -p "$cron_dir" || { echo "Error: Failed to create directory $cron_dir"; exit 1; }

# -------------------------------------
# Journal
# -------------------------------------
xray_access_log="$xray_log_dir/access.log"
xray_error_log="$xray_log_dir/error.log"

touch "$xray_access_log" || { echo "Error: Failed to create $xray_access_log file"; exit 1; }
touch "$xray_error_log" || { echo "Error: Failed to create $xray_error_log file"; exit 1; }
