#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line_1 {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function line_2 {
  echo -e "${RED}##############################################################################${NORMAL}"
}

function install_tools {
  sudo apt update && sudo apt install mc wget htop jq git -y
}

function install_docker {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash
}

function install_ufw {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash
}

function read_sepolia_rpc {
  if [ ! $RPC_URL ]; then
  echo -e "Введите ваш RPC Sepolia https url. Пример url'a - https://sepolia.infura.io/v3/ТУТ_ВАШ_КЛЮЧ"
  line_1
  read RPC_URL
  fi
}

function read_private_key {
  if [ ! $WAKU_PRIVATE_KEY ]; then
  echo -e "Введите ваш приватник от ETH кошелека на котором есть как минимум 0.1 ETH в сети Sepolia"
  line_1
  read WAKU_PRIVATE_KEY
  fi
}

function read_pass {
  if [ ! $WAKU_PASS ]; then
  echo -e "Введите(придумайте) пароль который будет использваться для сетапа ноды"
  line_1
  read WAKU_PASS
  fi
}

function git_clone {
  git clone https://github.com/waku-org/nwaku-compose
}

function setup_env {
  cd nwaku-compose
  cp .env.example .env

  sed -i "s|ETH_CLIENT_ADDRESS=.*|ETH_CLIENT_ADDRESS=$RPC_URL|" $HOME/nwaku-compose/.env
  sed -i "s|ETH_TESTNET_KEY=.*|ETH_TESTNET_KEY=$WAKU_PRIVATE_KEY|" $HOME/nwaku-compose/.env
  sed -i "s|RLN_RELAY_CRED_PASSWORD=.*|RLN_RELAY_CRED_PASSWORD=$WAKU_PASS|" $HOME/nwaku-compose/.env

  # Меняем стандартный порт графаны, на случай если кто-то баловался с другими нодами 
  # и она у него висит и занимает порт. Сыграем на опережение=)
  sed -i 's/0\.0\.0\.0:3000:3000/0.0.0.0:3004:3000/g' $HOME/nwaku-compose/docker-compose.yml

  bash $HOME/nwaku-compose/register_rln.sh
}


function docker_compose_up {
  docker compose -f $HOME/nwaku-compose/docker-compose.yml up -d
}

function echo_info {
  echo -e "${GREEN}Для остановки ноды waku: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml down \n ${NORMAL}"
  echo -e "${GREEN}Для запуска ноды и фармера waku: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml up -d \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки ноды waku: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml restart \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов ноды выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/nwaku-compose/docker-compose.yml logs -f --tail=100 \n ${NORMAL}"
  ip_address=$(hostname -I | awk '{print $1}') >/dev/null
  echo -e "${GREEN}Для проверки дашборда графаны, перейдите по ссылке: ${NORMAL}"
  echo -e "${RED}   http://$ip_address:3000/d/yns_4vFVk/nwaku-monitoring \n ${NORMAL}"
}

colors
line_1
logo
line_2
read_sepolia_rpc
line_2
read_private_key
line_2
read_pass
line_2
echo -e "Установка tools, ufw, docker"
line_1
install_tools
install_ufw
install_docker
line_1
echo -e "Клонируем репозиторий, готовим env и регистрируем rln"
line_1
git_clone
setup_env
line_1
echo -e "Запускаем docker контейнеры для waku"
line_1
docker_compose_up
line_2
echo_info
line_2
