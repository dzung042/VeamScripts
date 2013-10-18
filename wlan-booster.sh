#!/bin/bash
#
echo "	"
echo "	"
echo -e "\e[36m.d8888b.   888      8888888 	"
echo -e "\e[36md88P  Y88b 888        888   	"
echo -e "\e[36m888    888 888        888	"   
echo -e "\e[36m888        888        888   	"
echo -e "\e[36m888  88888 888        888   	"
echo -e "\e[36m888    888 888        888   	"
echo -e "\e[36mY88b  d88P 888        888   	"
echo -e "\e[36m .Y8888P88 88888888 8888888\e[0m	"
echo " "                             
echo " "                             
echo -e "\e[94m8888888 .d8888b.   .d8888b.	"  
echo -e "\e[94m  888  d88P  Y88b d88P  Y88b 	"
echo -e "\e[94m  888  Y88b.      Y88b.      	"
echo -e "\e[94m  888   *Y888b.    *Y888b.   	"
echo -e "\e[94m  888      *Y88b.     *Y88b. 	"
echo -e "\e[94m  888        *888       *888 	"
echo -e "\e[94m  888  Y88b  d88P Y88b  d88P 	"
echo -e "\e[94m8888888 *Y8888P*   *Y8888P*\e[0m	"
echo " "
echo " "
#
#                            
echo -e "This will allow you to change the wireless transmit power on compatible devices ie: \e[34mAlfa AWUS036NH\e[0m"
echo " "
#
echo "Enter wireless device you want to change"
read WIFI
#
wifidev="${WIFI}"
txpowerb=$(iwconfig $wifidev | awk '{ print $7 }' | head -n 1)
#
echo " "
echo -e "Current Transmit - \e[34m$txpowerb\e[0m"
echo "Enter dB - 20 default 30 max"
echo " "
read DB
echo " "
dbm="${DB}"
#
echo " "
echo -e "shutting down \e[31m$wifidev\e[0m"
ifconfig $wifidev down
sleep 3
#
echo " "
echo -e "setting Region to \e[34mBolivia\e[0m"
iw reg set BO
sleep 3
#
echo " "
echo -e "setting TxPower to \e[32m$dbm\e[0m"
iwconfig $wifidev txpower $dbm
sleep 2
#
echo " "
echo -e "starting up \e[32m$wifidev\e[0m"
ifconfig $wifidev up
sleep 2 
#
echo " "
echo -e "pulling $wifidev interface \e[32mup\e[0m"
echo " "
iwconfig $wifidev
#
sleep 2
txpowera=$(iwconfig $wifidev | awk '{ print $7 }' | head -n 1)
echo -e "Switched from \e[34m$txpowerb\e[0m to \e[34m$txpowera\e[0m"
echo " "
echo " "
sleep 2