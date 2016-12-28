#!/usr/bin/env bash
wget "https://valtman.name/files/telegram-cli-1215"
mv telegram-cli-1215 tg
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev lua-socket lua-sec lua-expat libevent-dev make unzip git redis-server autoconf g++ libjansson-dev libpython-dev expat libexpat1-dev ppa-purge python3-pip python3-dev
sudo pip3 install redis
sudo service redis-server restart
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo ppa-purge
chmod 777 tg
chmod 777 launch.sh
RED='\033[0;31m'
NC='\033[0m'
CYAN='\033[0;36m'
echo -e "${CYAN}Installation Completed! Create a bot with ./launch.sh ${NC}"
exit
