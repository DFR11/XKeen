# Function to delete selected GeoIP files
delete_geoip() {
    [ "$choice_delete_geoip_refilter_select" = "true" ] && rm -f "$geo_dir/geoip_refilter.dat"
    [ "$choice_delete_geoip_v2fly_select" = "true" ] && rm -f "$geo_dir/geoip_v2fly.dat"
    [ "$choice_delete_geoip_zkeenip_select" = "true" ] && rm -f "$geo_dir/geoip_zkeenip.dat" "$geo_dir/zkeenip.dat"
}

# Function to delete all GeoIP files
delete_geoip_key() {
    rm -f "$geo_dir/geoip_refilter.dat" \
          "$geo_dir/geoip_v2fly.dat" \
          "$geo_dir/geoip_zkeenip.dat" \
          "$geo_dir/zkeenip.dat"
}