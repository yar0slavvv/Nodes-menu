#!/bin/bash

logo="bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)"

if [ "$logo" == "bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)" ]; then
  clear
  bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)

echo "———————— Інстурменти для: ————————"
echo "     "
echo -e "(\033[38;5;244m1\033[0m) SubSpace          (\033[38;5;244m2\033[0m) Shardeum"
echo -e "(\033[38;5;244m3\033[0m) Meson             (\033[38;5;244m4\033[0m) Muon"
echo -e "(\033[38;5;244m5\033[0m) Nibiru            (\033[38;5;244m6\033[0m) Starknet"
echo -e "(\033[38;5;244m7\033[0m) Повернутися       (\033[38;5;244m8\033[0m) -"
echo -e "(\033[38;5;244m9\033[0m) -                 (\033[38;5;244m10\033[0m) -"
echo "     "
echo "__________________________________"
echo "     "
while true; do
read choice

case $choice in
 1)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/nodes/subspace)
    ;;
 2)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/nodes/shardeum)
    ;;
 3)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/nodes/meson)
    ;;
 4)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/nodes/muon)
    ;;
 5)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/nodes/nibiru)
    ;;
 6)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/uninstall/starknet)
    ;;
 7)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/choice)
    ;;
 *)
    echo "Невірний вибір"
    ;;
esac
done

else
  bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/acho)
fi
