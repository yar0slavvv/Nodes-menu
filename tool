#!/bin/bash

logo="bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)"

if [ "$logo" == "bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)" ]; then
  clear
  bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/cpi)

echo "—————————— Інструменти: ——————————"
echo ""
echo -e "(\033[38;5;244m1\033[0m) Керувати нодами"
echo -e "(\033[38;5;244m2\033[0m) Встановити/оновити Docker+comp."
echo -e "(\033[38;5;244m3\033[0m) Оновити пакети + бібліотеку"
echo -e "(\033[38;5;244m4\033[0m) Перевірити кількість пам'яті"
echo -e "(\033[38;5;244m5\033[0m) Повернутися"
echo ""
echo "__________________________________"
echo ""
while true; do
read choice

case $choice in
 1)
    echo " "
    echo "в розробці)"
    echo " "
    ;;
 2)
    echo " "
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/soft-installers/docker-install.sh)
    ;;
 3)
    echo " "
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/soft-installers/sudo-tools)
    ;;
 4)
    bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/main-menu)
    ;;
 5)
    avail_space=`df $PWD -h | awk '/[0-9]%/{print $(NF-2)}' | sed 's/.$//'`
    echo "Наразі ви маєте $avail_space гб вільного місця"
    ;;
 *)
    echo "Невірний вибір"
    ;;
esac
done

else
  bash <(curl -s https://yar0slavvv.github.io/CPI-Nodes/logos/acho)
fi
