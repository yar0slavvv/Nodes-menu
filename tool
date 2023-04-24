#!/bin/bash

logo="bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)"

if [ "$logo" == "bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)" ]; then
  clear
  bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)

  echo "—————————— Інструменти: ——————————"
  echo ""
  echo -e "(\033[38;5;244m1\033[0m) Керувати нодами"
  echo -e "(\033[38;5;244m2\033[0m) Встановити/оновити Docker
  echo -e "(\033[38;5;244m3\033[0m) Оновити пакети"
  echo -e "(\033[38;5;244m7\033[0m) -
  echo -e "(\033[38;5;244m9\033[0m) -
  echo ""
  echo "__________________________________"
  echo ""
while true; do
read choice

case $choice in
 1)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/tools/nodes-tools)
    ;;
 3)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/soft-installers/docker-install.sh)
    ;;
 2)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/soft-installers/sudo-tools)
    ;;
 *)
    echo "Невірний вибір"
    ;;
esac
done

else
  bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/acho)
fi
