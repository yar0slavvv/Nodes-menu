#!/bin/bash

logo="bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)"

if [ "$logo" == "bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)" ]; then
  clear
  bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)

echo "—————————— Інстурменти: ——————————"
echo "     "
echo -e "(\033[38;5;244m1\033[0m) Керувати нодами            (\033[38;5;244m2\033[0m) Оновити пакети
echo -e "(\033[38;5;244m3\033[0m) Встановити/оновити Docker  (\033[38;5;244m4\033[0m) -"
echo -e "(\033[38;5;244m5\033[0m) -                          (\033[38;5;244m6\033[0m) -"
echo -e "(\033[38;5;244m7\033[0m) -                          (\033[38;5;244m8\033[0m) -"
echo -e "(\033[38;5;244m9\033[0m) -                         (\033[38;5;244m10\033[0m) -"
echo "     "
echo "__________________________________"
echo "     "
while true; do
read choice

case $choice in
 1)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/tools/nodes-tools)
    ;;
 2)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/soft-installer/docker)
    ;;
 3)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/nodes/meson)
    ;;
 *)
    echo "Невірний вибір"
    ;;
esac
done

else
  bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/acho)
fi
