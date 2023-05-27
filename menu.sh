BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
UWhite='\033[4;37m'       # White
On_IPurple='\033[0;105m'  #
On_IRed='\033[0;101m'
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
NC='\e[0m'

# // Export Color & Information
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

# // Export Banner Status Information
export EROR="[${RED} EROR ${NC}]"
export INFO="[${YELLOW} INFO ${NC}]"
export OKEY="[${GREEN} OKEY ${NC}]"
export PENDING="[${YELLOW} PENDING ${NC}]"
export SEND="[${YELLOW} SEND ${NC}]"
export RECEIVE="[${YELLOW} RECEIVE ${NC}]"

# // Export Align
export BOLD="\e[1m"
export WARNING="${RED}\e[5m"
export UNDERLINE="\e[4m"

# // Exporting URL Host
export Server_URL="raw.githubusercontent.com/xlord27/test/main"
export Server1_URL="raw.githubusercontent.com/xlord27/limit/main"
export Server_Port="443"
export Server_IP="underfined"
export Script_Mode="Stable"
export Auther=".geovpn"
export MYIP=$( curl -s https://ipinfo.io/ip/ )
Name=$(curl -sS https://raw.githubusercontent.com/xlord27/Autoscript-vpn/main/izin | grep $MYIP | awk '{print $2}')
Exp=$(curl -sS https://raw.githubusercontent.com/xlord27/Autoscript-vpn/main/izin | grep $MYIP | awk '{print $3}')

# // Root Checking
if [ "${EUID}" -ne 0 ]; then
		echo -e "${EROR} Please Run This Script As Root User !"
		exit 1
fi

# // Exporting IP Address
export IP=$( curl -s https://ipinfo.io/ip/ )

# // Exporting Network Interface
export NETWORK_IFACE="$(ip route show to default | awk '{print $5}')"

#KonZ
vlx=$(grep -c -E "^#vl# " "/etc/xray/config.json")
let vla=$vlx/2
vmc=$(grep -c -E "^#vm# " "/etc/xray/config.json")
let vma=$vmc/2
ssh1="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
trx=$(grep -c -E "^#tr# " "/etc/xray/config.json")
let trb=$trx/2
ssx=$(grep -c -E "^#ss# " "/etc/xray/config.json")
let ssa=$ssx/2

# TOTAL RAM
total_ram=` grep "MemTotal: " /proc/meminfo | awk '{ print $2}'`
totalram=$(($total_ram/1024))

# // Clear
clear
clear && clear && clear
clear;clear;clear
cek=$(service ssh status | grep active | cut -d ' ' -f5)
if [ "$cek" = "active" ]; then
stat=-f5
else
stat=-f7
fi
ngx=$(service nginx status | grep active | cut -d ' ' $stat)
if [ "$ngx" = "active" ]; then
resngx="${green}ON${NC}"
else
resngx="${red}OFF${NC}"
fi
v2r=$(service xray status | grep active | cut -d ' ' $stat)
if [ "$v2r" = "active" ]; then
resv2r="${green}ON${NC}"
else
resv2r="${red}OFF${NC}"
fi
function addhost(){
clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -rp "Domain/Host: " -e host
echo ""
if [ -z $host ]; then
echo "????"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n 1 -s -r -p "Press any key to back on menu"
setting-menu
else
rm -fr /etc/xray/domain
echo "IP=$host" > /var/lib/scrz-prem/ipvps.conf
echo $host > /etc/xray/domain
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo "Dont forget to renew gen-ssl"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
fi
}
function genssl(){
clear
systemctl stop nginx
systemctl stop xray
domain=$(cat /var/lib/scrz-prem/ipvps.conf | cut -d'=' -f2)
Cek=$(lsof -i:80 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
if [[ ! -z "$Cek" ]]; then
sleep 1
echo -e "[ ${red}WARNING${NC} ] Detected port 80 used by $Cek " 
systemctl stop $Cek
sleep 2
echo -e "[ ${green}INFO${NC} ] Processing to stop $Cek " 
sleep 1
fi
echo -e "[ ${green}INFO${NC} ] Starting renew gen-ssl... " 
sleep 2
/root/.acme.sh/acme.sh --upgrade
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
echo -e "[ ${green}INFO${NC} ] Renew gen-ssl done... " 
sleep 2
echo -e "[ ${green}INFO${NC} ] Starting service $Cek " 
sleep 2
echo $domain > /etc/xray/domain
systemctl start nginx
systemctl start xray
echo -e "[ ${green}INFO${NC} ] All finished... " 
sleep 0.5
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
}
IPVPS=$(curl -s ipinfo.io/ip )
ISPVPS=$( curl -s ipinfo.io/org )
ttoday="$(vnstat | grep today | awk '{print $8" "substr ($9, 1, 3)}' | head -1)"
tmon="$(vnstat -m | grep `date +%G-%m` | awk '{print $8" "substr ($9, 1 ,3)}' | head -1)"
clear
echo -e "\033[0;34m╒═════════════════════════════════════════════════════════════╕
      ${NC}Welcome To ${GREEN}XLORD ${NC}Script installer ${GREEN}(PREMIUM)
         ${NC} This Script Coded on Bash & Python Language
        This Will Quick Setup VPN Server On Your Server
                   Owner : ${GREEN} XLORD TUNNELING
             ${NC}Copyright © By: t.me/xlordeuyy (2022-2033)
 ${yl}
 =============(Script Auto instal: XLORD TUNNELING)============"
echo -e "\033[0;34m╘═════════════════════════════════════════════════════════════╛\033[0m${NC}"
echo -e "\033[0;34m╒═════════════════════════════════════════════════════════════╕${NC}"
echo -e "${BICyan}   \033[0m ${BOLD}${YELLOW}SSH     VMESS       VLESS      TROJAN       SHADOWSOCKS$NC ${BICyan} "
echo -e "${BICyan}   \033[0m ${BICyan} $ssh1       $vma           $vla          $trb              $ssa   $NC   ${BICyan}" 
echo -e "\033[0;34m╘═════════════════════════════════════════════════════════════╛\033[0m${NC}"
echo -e "\033[0;34m╒═════════════════════════════════════════════════════════════╕\033[0m${NC}"
echo -e "     ${BIYellow} NGINX ${NC}: ${GREEN}$resngx         ${ICyan} Today  : $ttoday"
echo -e "     ${BIYellow} XRAY  ${NC}: ${GREEN}$resv2r         ${ICyan} Monthly: $tmon"
echo -e "     ${BIYellow} SSH   ${NC}: ${GREEN}ON"
echo -e "\033[0;34m╘═════════════════════════════════════════════════════════════╛\033[0m${NC}"
echo -e "\033[0;34m╒═════════════════════════════════════════════════════════════╕\033[0m${NC}"
echo -e " \E[41;1;39m                     ⇱ INFORMASI VPS ⇲                       \E[0m"
echo -e "\033[0;34m╘═════════════════════════════════════════════════════════════╛\033[0m${NC}"  
echo -e "  ✪$bd Use Core     :   ${BIYellow}multiport"
echo -e "${BIYellow}  ✪ ${BIYellow}TOTAL RAM       :  ${BIYellow}${totalram}MB"
echo -e "  ✪$bd IP VPS       :   ${BIYellow}$IPVPS${NC}"  
echo -e "  ✪$bd ISP VPS      :   ${BIYellow}$ISPVPS${NC}"   
echo -e "  ✪$bd Current Domain : ${BIYellow}$(cat /etc/xray/domain)${NC}" 
echo -e "  ✪$bd Status Hari ini  : ${IRed}𝗝𝗔𝗡𝗚𝗔𝗡 𝗟𝗨𝗣𝗔 𝗦𝗛𝗢𝗟𝗔𝗧"
echo -e "\033[0;34m╒═════════════════════════════════════════════════════════════╕\033[0m${NC}"
echo -e " \E[41;1;39m                     ⇱ MENU PANEL VPS ⇲                      \E[0m"
echo -e "\033[0;34m╘═════════════════════════════════════════════════════════════╛\033[0m${NC}"
echo -e ""
echo -e " ${BICyan}[${BIWhite}01${BICyan}]${RED} •${NC} ${CYAN}SSH MENU        $NC  ${BICyan}[${BIWhite}12${BICyan}]${RED} • ${NC}${CYAN}GEN-SSL / CERTV $NC"
echo -e " ${BICyan}[${BIWhite}02${BICyan}]${RED} •${NC} ${CYAN}VMESS MENU      $NC  ${BICyan}[${BIWhite}13${BICyan}]${RED} • ${NC}${CYAN}BANNER CHAGE $NC"
echo -e " ${BICyan}[${BIWhite}03${BICyan}]${RED} •${NC} ${CYAN}VLESS MENU      $NC  ${BICyan}[${BIWhite}14${BICyan}]${RED} • ${NC}${CYAN}CEK RUNNING SERVICE $NC"
echo -e " ${BICyan}[${BIWhite}04${BICyan}]${RED} •${NC} ${CYAN}TROJAN MENU     $NC  ${BICyan}[${BIWhite}15${BICyan}]${RED} • ${NC}${CYAN}CEK TRAFIC $NC"
echo -e " ${BICyan}[${BIWhite}05${BICyan}]${RED} •${NC} ${CYAN}S-SOCK MENU     $NC  ${BICyan}[${BIWhite}16${BICyan}]${RED} • ${NC}${CYAN}SPEEDTEDT  $NC"
echo -e " ${BICyan}[${BIWhite}06${BICyan}]${RED} •${NC} ${CYAN}MENU BACKUP     $NC  ${BICyan}[${BIWhite}17${BICyan}]${RED} • ${NC}${CYAN}CEK BANDWIDTH USE $NC"
echo -e " ${BICyan}[${BIWhite}07${BICyan}]${RED} •${NC} ${CYAN}AUTO REBOOT     $NC  ${BICyan}[${BIWhite}18${BICyan}]${RED} • ${NC}${CYAN}LIMMIT SPEED $NC"
echo -e " ${BICyan}[${BIWhite}08${BICyan}]${RED} •${NC} ${CYAN}REBOOT          $NC  ${BICyan}[${BIWhite}19${BICyan}]${RED} • ${NC}${CYAN}WEBMIN $NC"
echo -e " ${BICyan}[${BIWhite}09${BICyan}]${RED} •${NC} ${CYAN}RESTART SERVICE $NC  ${BICyan}[${BIWhite}20${BICyan}]${RED} • ${NC}${CYAN}SCRIPT INFO $NC"
echo -e " ${BICyan}[${BIWhite}10${BICyan}]${RED} •${NC} ${CYAN}BACKUP {OFF}    $NC  ${BICyan}[${BIWhite}21${BICyan}]${RED} • ${NC}${CYAN}CLEAR LOG $NC"
echo -e " ${BICyan}[${BIWhite}11${BICyan}]${RED} •${NC} ${CYAN}ADD HOST        $NC  ${BICyan}[${BIWhite}22${BICyan}]${RED} • ${NC}${CYAN}FIX MISSING POINTING $NC"
echo -e " ${BICyan}[${BIWhite} X ${BICyan}] TYPE X FOR EXIT ${BICyan}${BIYellow}${BICyan}${NC}"  
echo -e "\033[0;34m╒═════════════════════════════════════════════════════════════╕\033[0m${NC}"
echo -e " \E[41;1;39m                ⇱ 𝗫𝗟𝗢𝗥𝗗 𝗣𝗥𝗢𝗝𝗘𝗖𝗧 𝗩𝗣𝗡 ⇲                   \e[0m"
echo -e "\033[0;34m╘═════════════════════════════════════════════════════════════╛\033[0m${NC}"

echo -e "${BICyan}┌──────────────────────────────────────────────────┐${NC}"
echo -e "${BICyan}│ ${BOLD}${LIGHT}Client    = $Name                           ${NC}"
echo -e "${BICyan}│ ${BOLD}${LIGHT}Expired   = $Exp                            ${NC}"
echo -e "${BICyan}│ ${BOLD}${LIGHT}Developer = XLORD TUNNELING                      ${NC}"
echo -e "${BICyan}│ ${BOLD}${LIGHT}Version   = NEXT UPDATE                      ${NC}"

echo -e "${BICyan}└──────────────────────────────────────────────────┘${NC}"

echo
read -p " Select menu : " opt
echo -e ""
case $opt in
1) clear ; menu-ssh ;;
2) clear ; menu-vmess ;;
3) clear ; menu-vless ;;
4) clear ; menu-trojan ;;
5) clear ; menu-ss ;;
6) clear ; menu-backup ;;
7) clear ; autoreboot ;;
8) clear ; reboot ;;
9) clear ; restart ;;
10) clear ; menu ;;
11) clear ; addhost ;;
12) clear ; genssl ;;
13) clear ; nano /etc/issue.net ;;
14) clear ; running ;;
15) clear ; cek-trafik ;;
16) clear ; cek-speed ;;
17) clear ; cek-bandwidth ;;
#18) clear ; cek-ram ;;
18) clear ; limit-speed ;;
19) clear ; wbm ;;
20) clear ; cat /root/log-install.txt ;;
21) clear ; clearlog ;;
#99) clear ; update ;;
22) clear ; fix ;;

0) clear ; menu ;;
x) exit ;;
*) echo -e "" ; echo "Press any key to back exit" ; sleep 1 ; ./menu ;;
esac
