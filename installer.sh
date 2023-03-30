#!/usr/bin/env bash
set -e

if whiptail --title "CPI.TM" --yesno "З запуском цього інсталятора, ви дозволите команді Шардеум збирати вашу інформацію?" 10 50; then
  echo "Diagnostic data collection agreement accepted. Continuing with installer."
else
  echo "Diagnostic data collection agreement not accepted. Exiting installer."
  exit
fi
 
 (
echo "XXX"
echo "50"
echo "Doing something, please wait..."
curl -s https://yar0slavvv.github.io/CPI-Nodes/dchek
echo "XXX"
echo "100"
echo "Done."
) | whiptail --title "Progress" --gauge "Please wait" 6 50 0

RUNDASHBOARD=$(whiptail --title "CPI.TM" --yesno "Бажаєте запустити веб-інтерфейс?" 10 50 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus != 0 ]; then
    echo "Скасовано."
    exit
fi

unset CHARCOUNT
while true ; do
  PASSWORD=$(whiptail --title "CPI.TM" --passwordbox "Створіть ваш пароль до веб-інтерфейсу:" 10 50 3>&1 1>&2 2>&3)
  CHARCOUNT=${#PASSWORD}

  if [ $CHARCOUNT -eq 0 ] ; then
    whiptail --title "Помилка" --msgbox "Пароль не може бути порожнім. Спробуйте ще раз." 8 50
    continue
  else
    break
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


echo # New line after inputs.
# echo "Password saved as:" $DASHPASS #DEBUG: TEST PASSWORD WAS RECORDED AFTER ENTERED.

while true
do

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

while true; do
  SHMEXT=$(whiptail --title "CPI.TM" --inputbox "Введіть номер порту (1025-65536) для p2p-комунікації (за замовчуванням 9001):" 10 70 9001 3>&1 1>&2 2>&3)
  
  SHMEXT=${SHMEXT:-9001}
  if [[ $SHMEXT =~ ^[0-9]+$ ]]; then
    if ((SHMEXT >= 1025 && SHMEXT <= 65536)); then
      break
    else
      whiptail --title --msgbox "Введіть коректний номер порту (1025-65536)" 10 50
    fi
  else
    whiptail --title --msgbox "Введіть коректний номер порту (1025-65536)" 10 50
  fi
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


###########################
# 1. Pull Compose Project #
###########################

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


###############################
# 2. Create and Set .env File #
###############################

SERVERIP=$(curl ifconfig.me)
LOCALLANIP=$(curl ifconfig.me)
cd ${NODEHOME} &&
APP_IP=auto
EXISTING_ARCHIVERS=[{"ip":"18.194.3.6","port":4000,"publicKey":"758b1c119412298802cd28dbfa394cdfeecc4074492d60844cc192d632d84de3"},{"ip":"139.144.19.178","port":4000,"publicKey":"840e7b59a95d3c5f5044f4bc62ab9fa94bc107d391001141410983502e3cde63"},{"ip":"139.144.43.47","port":4000,"publicKey":"7af699dd711074eb96a8d1103e32b589e511613ebb0c6a789a9e8791b2b05f34"},{"ip":"72.14.178.106","port":4000,"publicKey":"2db7c949632d26b87d7e7a5a4ad41c306f63ee972655121a37c5e4f52b00a542"}]
APP_MONITOR=${APPMONITOR}
DASHPASS=${DASHPASS}
DASHPORT=${DASHPORT}
SERVERIP=${SERVERIP}
LOCALLANIP=${LOCALLANIP}
SHMEXT=${SHMEXT}
SHMINT=${SHMINT}


##########################
# 3. Clearing Old Images #
##########################

./cleanup.sh

##########################
# 4. Building base image #
##########################


cd ${NODEHOME} &&
docker-safe build --no-cache -t local-dashboard -f Dockerfile --build-arg RUNDASHBOARD=${RUNDASHBOARD} .


############################
# 5. Start Compose Project #
############################


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
  To use the Web Dashboard:
    1. Note the IP address that you used to connect to the node. This could be an external IP, LAN IP or localhost.
    2. Open a web browser and navigate to the web dashboard at https://<Node IP address>:$DASHPORT
    3. Go to the Settings tab and connect a wallet.
    4. Go to the Maintenance tab and click the Start Node button.

  If this validator is on the cloud and you need to reach the dashboard over the internet,
  please set a strong password and use the external IP instead of localhost.

fi


To use the Command Line Interface:
	1. Navigate to the Shardeum home directory ($NODEHOME).
	2. Enter the validator container with ./shell.sh.
	3. Run "operator-cli --help" for commands
