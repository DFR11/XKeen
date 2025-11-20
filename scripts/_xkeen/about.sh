about_xkeen() {
    echo
    printf "The ${green}XKeen${reset} utility is designed to manage the firewall\n of the ${yellow}Keenetic${reset} router, which protects the home network.\n The developers of ${red} are not responsible${reset} for the use\n of ${green}XKeen${reset} beyond its intended purpose. Before using, please ensure\n that your actions comply with the laws of your country.\n Using ${green}XKeen${reset} for illegal purposes ${red} is strictly prohibited${reset}.\n"
}

author_donate() {
    echo
    echo "Choose a method convenient for you:"
    echo
    echo -e "Support the author of the original XKeen (${green}Skrill0${reset})"
    echo "1. T-Bank"
    echo "2. DonationAlerts/ЮMoney"
    echo "     3. Crypto"
    echo
    echo -e "Support the developer of the XKeen fork (${green}jameszero${reset})"
    echo "4. MIR map"
    echo "5. CloudTips/ЮMoney"
    echo "     6. Crypto"
    echo
    echo "0. Cancel"
    echo

    while true; do
        read -r -p "Your choice:" choice
        case "$choice" in
            1)
                echo
                echo -e "${yellow}Direct link${reset}"
                echo "     https://www.tbank.ru/rm/krasilnikova.alina18/G4Z9433893"
                echo
                echo -e "${yellow}Card number${reset}"
                echo "     2200 7008 8716 3128"
                echo
                return 0
                ;;
            2)
                echo
                echo -e "${yellow}Direct link DonationAlerts${reset}"
                echo "     https://www.donationalerts.com/r/skrill0"
                echo
                echo -e "${yellow}Direct link YuMoney${reset}"
                echo "     https://yoomoney.ru/to/410018052017678"
                echo
                echo -e "${yellow}UMoney wallet number${reset}"
                echo "     4100 1805 201 7678"
                echo
                return 0
                ;;
            3)
                echo
                echo -e "  ${yellow}USDT${reset}, TRC20"
                echo "     tsc6emx5khk4cpyfkwj7dusybokravxs3m"
                echo
                echo -e "${yellow}USDT${reset}, ERC20 и BEP20"
                echo "     0x4a0369a762e3a23cc08f0bbbf39e169a647a5661"
                echo
                echo -e "${light_blue}Check that your details are up to date before transferring${reset}"
                echo
                return 0
                ;;
            4)
                echo
                echo -e "${yellow}MIR Map${reset} YuMoney"
                echo "     2204 1201 2976 4110"
                echo
                return 0
                ;;
            5)
                echo
                echo -e "${yellow}Direct link CloudTips${reset}"
                echo "     https://pay.cloudtips.ru/p/7edb30ec"
                echo
                echo -e "${yellow}Direct link YuMoney${reset}"
                echo "     https://yoomoney.ru/to/41001350776240"
                echo
                echo -e "${yellow}UMoney wallet number${reset}"
                echo "     4100 1350 7762 40"
                echo
                return 0
                ;;
            6)
                echo
                echo -e "  ${yellow}USDT${reset}, TRC20"
                echo "     TQhy1LbuGe3Bz7EVrDYn67ZFLDjDBa2VNX"
                echo
                echo -e "  ${yellow}USDT${reset}, ERC20"
                echo "     0x6a5DF3b5c67E1f90dF27Ff3bd2a7691Fad234EE2"
                echo
                echo -e "${light_blue}Check that your details are up to date before transferring${reset}"
                echo
                return 0
                ;;
            0)
                echo
                echo -e "${yellow}Thank you ${reset} for checking out the opportunity to support the developers"
                echo
                return 0
                ;;
            *)
                echo -e "${red}Invalid input${reset}"
                ;;
        esac
    done
}

author_feedback() {
    echo
    echo -e "${green}Developer contacts${reset}"
    echo
    echo -e "${light_blue}Author of the original XKeen${reset}:"
    echo -e "${yellow}Forum profile keenetic${reset}:"
    echo "     https://forum.keenetic.ru/profile/73583-skrill0"
    echo -e "  ${yellow}e-mail${reset}:"
    echo "     alinajoeyone@gmail.com"
    echo -e "  ${yellow}telegram${reset}:"
    echo "     @Skrill_zerro"
    echo -e "${yellow}telegram assistant${reset}:"
    echo "     @skride"
    echo
    echo -e "${light_blue}Developer of the XKeen${reset} fork:"
    echo -e "${yellow}Forum profile keenetic${reset}:"
    echo "     https://forum.keenetic.ru/profile/20945-jameszero"
    echo -e "  ${yellow}e-mail${reset}:"
    echo "     admin@jameszero.net"
    echo -e "  ${yellow}telegram${reset}:"
    echo "     @jameszero"
    echo -e "${yellow}site${reset}:"
    echo "     https://jameszero.net"
    echo -e "  ${yellow}GitHub${reset}:"
    echo "     https://github.com/jameszeroX"
    echo
    echo -e "The contacts provided above are ${green}for personal correspondence${reset}, and ${red}not for consultations${reset}"
    echo "If you have any questions about XKeen, ask in telegram chat https://t.me/+8Cvh7oVf6cE0MWRi"
}

help_xkeen() {
        echo
        echo -e "${yellow}Installation${reset}"
        echo -e "-i ${italic} Basic installation mode XKeen + Xray + GeoFile + Mihomo${reset}"
        echo -e "-io ${italic} OffLine setting XKeen${reset}"
        echo
        echo -e "${yellow}Update${reset}"
        echo -e "	-uk	${italic}	XKeen${reset}"
        echo -e "	-ug	${italic}	GeoFile${reset}"
        echo -e "-ux ${italic} Xray${reset} (upgrade/downgrade)"
        echo -e "-um ${italic} Mihomo${reset} (upgrade/downgrade)"
        echo
        echo -e "${yellow}Enabling or changing the auto-update task${reset}"
        echo -e "	-ugc	${italic}	GeoFile${reset}"
        echo
        echo -e "${yellow}Registration${reset}"
        echo -e "	-rrk	${italic}	XKeen${reset}"
        echo -e "	-rrx	${italic}	Xray${reset}"
        echo -e "	-rrm	${italic}	Mihomo${reset}"
        echo -e "-ri ${italic} Autostart XKeen using init.d${reset}"
        echo
        echo -e "${red}Delete${reset} | Utilities and components"
        echo -e "-remove ${italic} Complete uninstallation of XKeen${reset}"
        echo -e "	-dgs	${italic}	GeoSite${reset}"
        echo -e "	-dgi	${italic}	GeoIP${reset}"
        echo -e "	-dx	${italic}	Xray${reset}"
        echo -e "	-dm	${italic}	Mihomo${reset}"
        echo -e "	-dk	${italic}	XKeen${reset}"
        echo
        echo -e "${red}Delete${reset} | Auto-update tasks"
        echo -e "	-dgc	${italic}	GeoFile${reset}"
        echo
        echo -e "${red}Delete${reset} | Registrations in the system"
        echo -e "	-drk	${italic}	XKeen${reset}"
        echo -e "	-drx	${italic}	Xray${reset}"
        echo -e "	-drm	${italic}	Mihomo${reset}"
        echo
        echo -e "${green}Ports${reset} | Through which the proxy client works"
        echo -e "-ap ${italic} Add${reset}"
        echo -e "-dp ${italic} Delete${reset}"
        echo -e "-cp ${italic} View${reset}"
        echo
        echo -e "${green}Ports${reset} | Excluded from the proxy client"
        echo -e "-ape ${italic} Add${reset}"
        echo -e "-dpe ${italic} Delete${reset}"
        echo -e "-cpe ${italic} View${reset}"
        echo
        echo -e "${green}Reinstallation${reset}"
        echo -e "	-k	${italic}	XKeen${reset}"
        echo -e "	-g	${italic}	GeoFile${reset}"
        echo
        echo -e "${green}XKeen backup ${reset}"
        echo -e "-kb ${italic} Create${reset}"
        echo -e "-kbr ${italic} Restore${reset}"
        echo
        echo -e "${green}Xray configuration backup${reset}"
        echo -e "-cb ${italic} Create${reset}"
        echo -e "-cbr ${italic} Restore${reset}"
        echo
        echo -e "${green}Mihomo configuration backup${reset}"
        echo -e "-mb ${italic} Create${reset}"
        echo -e "-mbr ${italic} Restore${reset}"
        echo
        echo -e "${light_blue}Proxy client management${reset}"
        echo -e "-start ${italic} Start${reset}"
        echo -e "-stop ${italic} Stop${reset}"
        echo -e "-restart${italic} Restart${reset}"
        echo -e "-status ${italic} Job status${reset}"
        echo -e "-tpx ${italic} Ports, gateway and proxy client protocol${reset}"
        echo -e "-auto ${italic} Enable | Disable proxy client autostart${reset}"
        echo -e "-d ${italic} Set proxy client autostart delay${reset}"
        echo -e "-fd ${italic} Enable | Disable monitoring of file descriptors opened by the proxy client${reset}"
        echo -e "-diag ${italic} Run diagnostics${reset}"
        echo -e "-channel${italic} Switch the channel for receiving XKeen updates (Stable/Dev version)${reset}"
        echo -e "-xray ${italic} Switch XKeen to Xray${reset} kernel"
        echo -e "-mihomo ${italic} Switch XKeen to Mihomo${reset} kernel"
        echo
        echo -e "${light_blue}Module management${reset}"
        echo -e "-modules${italic} Move modules for XKeen to the user directory${reset}"
        echo -e "-delmodules${italic} Removing modules from the user directory${reset}"
        echo
        echo -e "${light_blue}Information${reset}"
        echo -e "-about ${italic} About ${reset}"
        echo -e "-ad ${italic} Support the developers${reset}"
        echo -e "-af ${italic} Feedback${reset}"
        echo -e "-v ${italic} Version XKeen${reset}"
}