# Function to delete selected GeoSite files
delete_geosite() {
    [ "$choice_delete_geosite_refilter_select" = "true" ] && rm -f "$geo_dir/geosite_refilter.dat"
    [ "$choice_delete_geosite_v2fly_select" = "true" ] && rm -f "$geo_dir/geosite_v2fly.dat"
    [ "$choice_delete_geosite_zkeen_select" = "true" ] && rm -f "$geo_dir/"geosite_zkeen.dat "$geo_dir/"zkeen.dat
}

# Function to delete all GeoSite files
delete_geosite_key() {
    rm -f "$geo_dir/geosite_refilter.dat" \
          "$geo_dir/geosite_v2fly.dat" \
          "$geo_dir/geosite_zkeen.dat" \
          "$geo_dir/zkeen.dat"
}