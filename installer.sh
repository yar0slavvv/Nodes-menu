#!/usr/bin/env bash

if whiptail --title "CPI.TM" --yesno "З запуском цього інсталятора, ви дозволите команді Шардеум збирати вашу інформацію" 10 50; then
  echo "Diagnostic data collection agreement accepted. Continuing with installer."
  WARNING_AGREE="y"
else
  echo "Diagnostic data collection agreement not accepted. Exiting installer."
  exit
fi

if [ $WARNING_AGREE != "y" ];
then
  echo "Diagnostic data collection agreement not accepted. Exiting installer."
  exit
fi

command -v git >/dev/null 2>&1 || { echo >&2 "'git' is required but not installed."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo >&2 "'docker' is required but not installed. See https://gitlab.com/shardeum/validator/dashboard/-/tree/dashboard-gui-nextjs#how-to for details."; exit 1; }
if command -v docker-compose &>/dev/null; then
  echo "docker-compose is installed on this machine"
elif docker --help | grep -q "compose"; then
  echo "docker compose subcommand is installed on this machine"
else
  echo "docker-compose or docker compose is not installed on this machine"
  exit 1
fi

export DOCKER_DEFAULT_PLATFORM=linux/amd64

docker-safe() {
  if ! command -v docker &>/dev/null; then
    echo "docker is not installed on this machine"
    exit 1
  fi

  if ! docker $@; then
    echo "Trying again with sudo..."
    sudo docker $@
  fi
}

docker-compose-safe() {
  if command -v docker-compose &>/dev/null; then
    cmd="docker-compose"
  elif docker --help | grep -q "compose"; then
    cmd="docker compose"
  else
    echo "docker-compose or docker compose is not installed on this machine"
    exit 1
  fi

  if ! $cmd $@; then
    echo "Trying again with sudo..."
    sudo $cmd $@
  fi
}

get_ip() {
  local ip
  if command -v ip >/dev/null; then
    ip=$(ip addr show $(ip route | awk '/default/ {print $5}') | awk '/inet/ {print $2}' | cut -d/ -f1 | head -n1)
  elif command -v netstat >/dev/null; then
    # Get the default route interface
    interface=$(netstat -rn | awk '/default/{print $4}' | head -n1)
    # Get the IP address for the default interface
    ip=$(ifconfig "$interface" | awk '/inet /{print $2}')
  else
    echo "Error: neither 'ip' nor 'ifconfig' command found. Submit a bug for your OS."
    return 1
  fi
  echo $ip
}

get_external_ip() {
  external_ip=''
  external_ip=$(curl -s https://api.ipify.org)
  if [[ -z "$external_ip" ]]; then
    external_ip=$(curl -s http://checkip.dyndns.org | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
  fi
  if [[ -z "$external_ip" ]]; then
    external_ip=$(curl -s http://ipecho.net/plain)
  fi
  if [[ -z "$external_ip" ]]; then
    external_ip=$(curl -s https://icanhazip.com/)
  fi
    if [[ -z "$external_ip" ]]; then
    external_ip=$(curl --header  "Host: icanhazip.com" -s 104.18.114.97)
  fi
  if [[ -z "$external_ip" ]]; then
    external_ip=$(get_ip)
    if [ $? -eq 0 ]; then
      echo "The IP address is: $IP"
    else
      external_ip="localhost"
    fi
  fi
  echo $external_ip
}

if [[ $(docker-safe info 2>&1) == *"Cannot connect to the Docker daemon"* ]]; then
    echo "Docker daemon is not running"
    exit 1
else
    echo "Docker daemon is running"
fi

clear

cat << EOF

###################################
# Для продовження натисніть Enter #
###################################

EOF

RUNDASHBOARD=$(whiptail --title "CPI.TM" --yesno "Бажаєте запустити веб-інтерфейс?" 10 50 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus != 0 ]; then
    echo "Скасовано."
    exit
fi

unset CHARCOUNT
PASSWORD=$(whiptail --title "CPI.TM" --passwordbox "Створіть ваш пароль до веб-інтерфейсу:" 10 50 3>&1 1>&2 2>&3)
  CHARCOUNT=${#PASSWORD}

while IFS= read -r -s -n 1 CHAR
do
  # Enter - accept password
  if [[ $CHAR == $'\0' ]] ; then
    if [ $CHARCOUNT -eq 0 ] ; then
      whiptail --title "Помилка" --msgbox "Пароль не може бути порожнім. Спробуйте ще раз." 8 50
      continue
    else
      break
    fi
  fi
  # Backspace
  if [[ $CHAR == $'\177' ]] ; then
    if [ $CHARCOUNT -gt 0 ] ; then
      CHARCOUNT=$((CHARCOUNT-1))
      PROMPT=$'\b \b'
      DASHPASS="${DASHPASS%?}"
    else
      PROMPT=''
    fi
  else
    CHARCOUNT=$((CHARCOUNT+1))
    PROMPT='*'
    DASHPASS+="$CHAR"
  fi
done

PASSWORD=$DASHPASS
unset CHARCOUNT

while :; do
  DASHPORT=$(whiptail --title "CPI.TM" --inputbox "Введіть номер порту (1025-65536) для веб-інтерфейсу (за замовчуванням 8080):" 10 70 8080 3>&1 1>&2 2>&3)

  DASHPORT=${DASHPORT:-8080}
  if [[ $DASHPORT =~ ^[0-9]+$ ]]; then
    if ((DASHPORT >= 1025 && DASHPORT <= 65536)); then
      DASHPORT=${DASHPORT:-8080}
      break
    else
      whiptail --title --msgbox "Введіть коректний порт (1025-65536)" 10 50
    fi
  else
    whiptail --title --msgbox "Введіть коректний порт (1025-65536)" 10 50
  fi
done

while :; do
  SHMEXT=$(whiptail --title "CPI.TM" --inputbox "Введіть другий номер порту (1025-65536) для p2p-комунікації (за замовчуванням 10001):" 10 70 10001 3>&1 1>&2 2>&3)
  
  SHMINT=${SHMINT:-9001}
  if [[ $SHMINT =~ ^[0-9]+$ ]]; then
    if ((SHMINT >= 1025 && SHMINT <= 65536)); then
      break
    else
      whiptail --title --msgbox "Введіть коректний номер порту (1025-65536)" 10 50
    fi
  else
    whiptail --title --msgbox "Введіть коректний номер порту (1025-65536)" 10 50
  fi
done

NODEHOME=$(whiptail --title "CPI.TM" --inputbox "Введіть директорію (за замовчуванням ~/.shardeum):" 10 70 ~/.shardeum 3>&1 1>&2 2>&3)
  
  NODEHOME=${NODEHOME:-~/.shardeum}

APPSEEDLIST="archiver-sphinx.shardeum.org"
APPMONITOR="monitor-sphinx.shardeum.org"

clear

cat <<EOF

###########################
# Обробка ваших данних #
###########################

EOF

if [ -d "$NODEHOME" ]; then
  if [ "$NODEHOME" != "$(pwd)" ]; then
    echo "Removing existing directory $NODEHOME..."
    rm -rf "$NODEHOME"
  else
    echo "Cannot delete current working directory. Please move to another directory and try again."
  fi
fi

git clone https://gitlab.com/shardeum/validator/dashboard.git ${NODEHOME} &&
  cd ${NODEHOME} &&
  chmod a+x ./*.sh

clear

cat <<EOF

########################################
# Створення і встановлення ./env файлу #
########################################

EOF

SERVERIP=$(get_external_ip)
LOCALLANIP=$(get_ip)
cd ${NODEHOME} &&
touch ./.env
cat >./.env <<EOL
APP_IP=auto
EXISTING_ARCHIVERS=[{"ip":"18.194.3.6","port":4000,"publicKey":"758b1c119412298802cd28dbfa394cdfeecc4074492d60844cc192d632d84de3"},{"ip":"139.144.19.178","port":4000,"publicKey":"840e7b59a95d3c5f5044f4bc62ab9fa94bc107d391001141410983502e3cde63"},{"ip":"139.144.43.47","port":4000,"publicKey":"7af699dd711074eb96a8d1103e32b589e511613ebb0c6a789a9e8791b2b05f34"},{"ip":"72.14.178.106","port":4000,"publicKey":"2db7c949632d26b87d7e7a5a4ad41c306f63ee972655121a37c5e4f52b00a542"}]
APP_MONITOR=${APPMONITOR}
DASHPASS=${DASHPASS}
DASHPORT=${DASHPORT}
SERVERIP=${SERVERIP}
LOCALLANIP=${LOCALLANIP}
SHMEXT=${SHMEXT}
SHMINT=${SHMINT}
EOL

clear

cat <<EOF

#########################
# Видалення старої ноди #
#########################

EOF

./cleanup.sh

clear

cat <<EOF

####################
# Створення образу #
####################

EOF

cd ${NODEHOME} &&
docker-safe build --no-cache -t local-dashboard -f Dockerfile --build-arg RUNDASHBOARD=${RUNDASHBOARD} .

clear

cat <<EOF

##################
# Запуск проекту #
##################

EOF

cd ${NODEHOME}
if [[ "$(uname)" == "Darwin" ]]; then
  sed "s/- '8080:8080'/- '$DASHPORT:$DASHPORT'/" docker-compose.tmpl > docker-compose.yml
  sed -i '' "s/- '9001-9010:9001-9010'/- '$SHMEXT:$SHMEXT'/" docker-compose.yml
  sed -i '' "s/- '10001-10010:10001-10010'/- '$SHMINT:$SHMINT'/" docker-compose.yml
else
  sed "s/- '8080:8080'/- '$DASHPORT:$DASHPORT'/" docker-compose.tmpl > docker-compose.yml
  sed -i "s/- '9001-9010:9001-9010'/- '$SHMEXT:$SHMEXT'/" docker-compose.yml
  sed -i "s/- '10001-10010:10001-10010'/- '$SHMINT:$SHMINT'/" docker-compose.yml
fi
./docker-up.sh

echo "Starting image. This could take a while..."
(docker-safe logs -f shardeum-dashboard &) | grep -q 'done'

#Do not indent
if [ $RUNDASHBOARD = "y" ]
then
cat <<EOF
Для використання веб-панелі керування:

Запам'ятайте IP-адресу, яку ви використовували для підключення до вузла. Це може бути зовнішній IP, місцевий IP або localhost.
Відкрийте веб-браузер і перейдіть до веб-панелі керування за адресою https://<IP-адреса вузла>:$DASHPORT
Перейдіть на вкладку "Налаштування" та підключіть гаманець.
Перейдіть на вкладку "Обслуговування" та натисніть кнопку "Запустити вузол".
Якщо цей валідатор знаходиться у хмарі, і вам потрібно отримати доступ до панелі керування через Інтернет,
будь ласка, встановіть міцний пароль та використовуйте зовнішній IP замість localhost.
EOF
fi

cat <<EOF

Для використання інтерфейсу командного рядка:

Перейдіть до домашньої директорії Shardeum ($NODEHOME).
Увійдіть до контейнера валідатора за допомогою ./shell.sh.
Виконайте "operator-cli --help" для отримання списку команд.

EOF
