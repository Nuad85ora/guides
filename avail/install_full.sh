#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  YELLOW="\e[33m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function get_nodename {
    if [ ! ${AVAIL_NODENAME} ]; then
    echo -e "${RED}Введите имя ноды(придумайте)${NORMAL}"
    line
    read AVAIL_NODENAME
    source $HOME/.profile
    fi
}

function install_main_tools {
    echo -e "${YELLOW}Установка основных зависимостей:${NORMAL}"
    bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh)
}

function wget_bin {
    echo -e "${YELLOW}Скачивание бинарников:${NORMAL}"
    if [[ $(lsb_release -rs) == "22.04" ]]; then
        wget https://github.com/availproject/avail/releases/download/v1.10.0.0/x86_64-ubuntu-2204-data-avail.tar.gz
        tar xvf x86_64-ubuntu-2204-data-avail.tar.gz
        rm -f x86_64-ubuntu-2204-data-avail.tar.gz
    else
        wget https://github.com/availproject/avail/releases/download/v1.10.0.0/x86_64-ubuntu-2004-data-avail.tar.gz
        tar xvf x86_64-ubuntu-2004-data-avail.tar.gz
        rm -f x86_64-ubuntu-2004-data-avail.tar.gz
    fi
    sudo mv data-avail /usr/bin/avail-full
    sudo chmod +x /usr/bin/avail-full
}

function wget_chainspec {
    echo -e "${YELLOW}Скачивание конфигурции сети:${NORMAL}"
    mkdir -p $HOME/.avail-full && cd $HOME/.avail-full
    wget -O $HOME/.avail-full/chainspec.raw.json "https://kate.avail.tools/chainspec.raw.json"
    chmod 744 ~/.avail-full/chainspec.raw.json
}

function create_systemd {
    echo -e "${YELLOW}Создание сервиса systemd:${NORMAL}"
    sudo tee <<EOF >/dev/null /etc/systemd/system/avail-full.service
[Unit]
Description=Avail Node
After=network-online.target
StartLimitIntervalSec=0
[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
ExecStart=/usr/bin/avail-full \
--base-path $HOME/.avail-full/data/ \
--chain goldberg \
--port 40333 \
--rpc-port 49933 \
--prometheus-port 49615 \
--validator \
--name '$AVAIL_NODENAME' \
--telemetry-url 'wss://telemetry.doubletop.io/submit 0' \
--telemetry-url 'ws://telemetry.avail.tools:8001/submit/ 0' \
--reserved-nodes \
"/dns/bootnode-001.goldberg.avail.tools/tcp/30333/p2p/12D3KooWCVqFvrP3UJ1S338Gb8SHvEQ1xpENLb45Dbynk4hu1XGN" \
"/dns/bootnode-002.goldberg.avail.tools/tcp/30333/p2p/12D3KooWD6sWeWCG5Z1qhejhkPk9Rob5h75wYmPB6MUoPo7br58m" \
"/dns/bootnode-003.goldberg.avail.tools/tcp/30333/p2p/12D3KooWMR9ZoAVWJv6ahraVzUCfacNbFKk7ABoWxVL3fJ3XXGDw" \
"/dns/bootnode-004.goldberg.avail.tools/tcp/30333/p2p/12D3KooWMuyLE3aPQ82HTWuPUCjiP764ebQrZvGUzxrYGuXWZJZV" \
"/dns/bootnode-005.goldberg.avail.tools/tcp/30333/p2p/12D3KooWKJwbdcZ7QWcPLHy3EJ1UiffaLGnNBMffeK8AqRVWBZA1" \
"/dns/bootnode-006.goldberg.avail.tools/tcp/30333/p2p/12D3KooWM8AaHDH8SJvg6bq4CGQyHvW2LH7DCHbdv633dsrti7i5" \
--reserved-only 
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable avail-full
sudo systemctl restart avail-full
}

function output {
    echo -e "${YELLOW}Нода установлена, идем проверять себя в телеметрии:${NORMAL}"
    echo -e "https://telemetry.doubletop.io/#list/0x6f09966420b2608d1947ccfb0f2a362450d1fc7fd902c29b67c906eaa965a7ae"
    echo -e "${YELLOW}Для проверки логов выполняем команду:${NORMAL}"
    echo -e "journalctl -n 100 -f -u avail-full -o cat"
    echo -e "${YELLOW}Для проверки логов выполняем команду:${NORMAL}"
    echo -e "sudo systemctl restart avail-full"
}

function main {
    colors
    logo
    line
    get_nodename
    line
    install_main_tools
    line
    wget_bin
    # line
    # wget_chainspec
    line
    create_systemd
    line
    output
}

main