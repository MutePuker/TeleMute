#!/usr/bin/env bash
wget "https://valtman.name/files/telegram-cli-1222"
mv telegram-cli-1222 tg
sudo apt-get update 
sudo apt-get upgrade
sudo apt-get install libreadline-dev libssl-dev lua5.2 liblua5.2-dev git make unzip redis-server curl libcurl4-gnutls-dev
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev make autoconf unzip git redis-server g++ libjansson-dev libpython-dev expat libexpat1-dev
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev make autoconf unzip git redis-server g++ libjansson-dev libpython-dev expat libexpat1-dev
sudo apt-get install libreadline-dev
sudo apt install libreadline-dev 
sudo apt-get install libreadline6 
sudo apt-get install libreadline6-dev
sudo apt-get install libconfig-dev 
sudo apt-get install libssl-dev 
sudo apt-get install lua5.2 
sudo apt-get install liblua5.2-dev 
sudo apt-get install lua-socket 
sudo apt-get install lua-sec 
sudo apt-get install lua-expat 
sudo apt-get install libevent-dev 
sudo apt-get install redis-server 
sudo apt-get install libjansson-dev 
sudo apt-get install libpython-dev 
sudo apt-get install expat libexpat1-dev 
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo apt-get install libreadline-dev
sudo apt install libreadline-dev 
sudo apt-get install libreadline6 
sudo apt-get install libreadline6-dev
sudo apt-get install libconfig-dev 
sudo apt-get install libssl-dev 
sudo apt-get install lua5.2 
sudo apt-get install liblua5.2-dev 
sudo apt-get install lua-socket 
sudo apt-get install lua-sec 
sudo apt-get install lua-expat 
sudo apt-get install libevent-dev 
sudo apt-get install make 
sudo apt-get install unzip 
sudo apt-get install git 
sudo apt-get install redis-server 
sudo apt-get install autoconf 
sudo apt-get install g++ 
sudo apt-get install libjansson-dev 
sudo apt-get install libpython-dev 
sudo apt-get install expat libexpat1-dev 
sudo apt-get install ppa-purge 
sudo apt-get install python3-pip 
sudo apt-get install python3-dev
sudo apt-get install software-properties-common
sudo apt-get install python-software-properties
sudo apt-get install gcc-6
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo ppa-purge
sudo service redis-server restart
sudo apt-get update 
sudo apt-get upgrade
 sudo apt-get install libreadline-dev libssl-dev lua5.2 liblua5.2-dev git make unzip redis-server curl libcurl4-gnutls-dev
wget http://luarocks.org/releases/luarocks-2.2.2.tar.gz 
 tar zxpf luarocks-2.2.2.tar.gz 
 cd luarocks-2.2.2
 ./configure; sudo make bootstrap 
sudo luarocks install luasec 
sudo luarocks install luasocket 
sudo luarocks install redis-lua 
sudo luarocks install lua-term 
sudo luarocks install serpent
sudo luarocks install dkjson 
sudo luarocks install Lua-cURL
cd ..
chmod 777 tg
chmod 777 launch.sh
RED='\033[0;31m'
NC='\033[0m'
CYAN='\033[0;36m'
echo -e "${CYAN}Installation Completed! Create a bot with launch(./launch.sh)${NC}"
exit
