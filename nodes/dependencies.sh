#!/bin/bash

echo -e "\033[1;97;42mОновлення пакетів...\033[0m"
sudo apt-get update &&
sudo apt-get install -y curl iptables build-essential git lz4 wget jq make gcc nano chrony \
tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev &&

echo -e "\033[1;97;42mВстановлення GO...\033[0m"
if ! [ -x "$(command -v go)" ]; then
  source <(curl -s "https://raw.githubusercontent.com/R1M-NODES/cosmos/master/utils/go_install.sh")
  source $HOME/.bash_profile
fi

