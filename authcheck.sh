#!/bin/bash
# - title        : MassBuild for Cloud Servers
# - description  : API Authentication Script
# - License      : GPLv3+
# - author       : Kevin Carter
# - date         : 2011-09-20
# - version      : 1.0    
# - usage        : bash authcheck.sh
# - notes        : This is a Cloud Build Script
# - bash_version : >= 3.2.48(1)-release

# This software has no warranty, it is provided “as is”. It is your responsibility 
# to validate the behavior of the routines and its accuracy using the code provided.  
# Consult the GNU General Public license for further details (see GNU General Public License).
# http://www.gnu.org/licenses/gpl.html

#### ========================================================= ####

if [ ! -f ./massinit.cfg ];then
    echo -e "You are not running the script from the proper directory.\nChange to the proper directory and try again."
    exit 1
        else
            source massinit.cfg
fi

trap CONTROL_C SIGINT

CONTROL_C(){
echo ''
echo "AAHAHAAHH! FIRE! CRASH AND BURN!"
echo "     You Pressed [ CTRL C ]     "
        QUIT
}

REST(){
    echo "Resting post Action..."
    sleep 65
}
##  Exit  ##
QUIT(){
  echo -e "\nExiting\nCleaning Up my mess...\n"
exit 0
}

# Check for Parallel
if [ "$(which parallel)" ];then
    echo "Parallel was found on the system"
    elif [ -f "bin/parallel" ];then
        echo "Using Statically Built Parallel Binary"
        export PATH=$(pwd)/bin:$PATH
        else
            echo -e "\nParallel was not installed on this system.\nYou can get GNU Parallel here : http://ftp.gnu.org/gnu/parallel/\nInstallation is simple, Download, Unzip, ./configure && make && make install\n"
            exit 1
fi

PYTHON=$(which python)
if [ ! "$PYTHON" ];then
    echo -e "\nPython was not found so I quit.\nPlease install python to continue\n"
    exit 1
fi

# RS Username 
if [ -z "$USERNAME" ];then 
  read -p "Enter your Username : " USERNAME
fi

# RS API Key 
if [ -z "$APIKEY" ];then 
  read -p "Enter your API Key : " APIKEY
fi

# Authentication v2.0 URL
if [ -z "$LOCAL" ];then
  read -p "Enter The Cloud Files Location, (us or uk) : " LOCAL
fi
if [ "$LOCAL" == "us" ];then
  AUTHURL='https://auth.api.rackspacecloud.com/v2.0'
elif [ "$LOCAL" == "uk" ];then
  AUTHURL='https://lon.auth.api.rackspacecloud.com/v2.0'
else 
  echo "You have to put in a Valid Location, which is \"us\" or \"uk\"."
  exit 1 
fi

# DC Selection if needed
if [ -z "$DC" ];then
    read -p "Enter The DC, (dfw, ord, lon | multi) : " DC
fi
  if [ "${DC}" == "dfw" ]; then
    echo "Using DFW"
      elif [ "${DC}" == "ord" ]; then
      echo "Using ORD"
        elif [ "${DC}" == "lon" ]; then
        echo "Using LON"
          elif [ "${DC}" == "multi" ]; then
          echo "Using both DFW and ORD"
            else
            echo "You did not specify one of the Datacenters (dfw, ord, lon | multi)"
    exit 1
  fi

# Creating a service list catalog
SERVICECAT=$( curl -s -X POST ${AUTHURL}/tokens -d " { \"auth\":{ \"RAX-KSKEY:apiKeyCredentials\":{ \"username\":\"${USERNAME}\", \"apiKey\":\"${APIKEY}\" }}}" -H "Content-type: application/json" | python -m json.tool )
echo -e "\nAuthenticating\n"

if [ "$(echo  $SERVICECAT | grep '"code": [3-5][0-9][0-9]')" ];then
  if [ "$(echo  $SERVICECAT | grep 'unauthorized')" ];then
      echo -e "\n\033[1;35mYour Credentials seem to be invalid please check your credentials and try again.\nHere is the API response :\033[0m\n$SERVICECAT\n"
      exit 1
  fi
    echo -e "\n\033[1;35mThere were errors found while Authenticating.\nHere is the API response :\033[0m\n$SERVICECAT\n" 
    exit 1
fi

# Setting the Token
TOKEN=$(echo $SERVICECAT | python -m json.tool | grep -A3 -i "token" | awk -F '"' '/id/ {print $4}')

# Settings Servers URL
if [ "$DC" == "multi" ];then
    ORDSERVERSURL=$(echo $SERVICECAT | python -m json.tool | grep -B18 -i "cloudServersOpenStack" | grep "ord" | awk -F '"' '/publicURL/ {print $4}')
    DFWSERVERSURL=$(echo $SERVICECAT | python -m json.tool | grep -B18 -i "cloudServersOpenStack" | grep "dfw" | awk -F '"' '/publicURL/ {print $4}')
        else
            SERVERSURL=$(echo $SERVICECAT | python -m json.tool | grep -B18 -i "cloudServersOpenStack" | grep "$DC" | awk -F '"' '/publicURL/ {print $4}')
fi
