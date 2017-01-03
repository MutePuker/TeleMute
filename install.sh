#!/usr/bin/env bash
wget "https://valtman.name/files/telegram-cli-1222"
mv telegram-cli-1124 tg
chmod 777 tg
chmod 777 launch.sh
RED='\033[0;31m'
NC='\033[0m'
CYAN='\033[0;36m'
echo -e "${CYAN}Installation Completed! Create a bot with launch(./launch.sh)${NC}"
exit
