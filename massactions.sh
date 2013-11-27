#!/bin/bash
# - title        : MassBuild for Cloud Servers
# - description  : This script will get the IP Addresses for a built series
# - License      : GPLv3+
# - author       : Kevin Carter
# - date         : 2011-09-20
# - version      : 1.0    
# - usage        : bash massreboot.sh
# - notes        : reboot all instances
# - bash_version : >= 3.2.48(1)-release

# This software has no warranty, it is provided “as is”. It is your responsibility 
# to validate the behavior of the routines and its accuracy using the code provided.  
# Consult the GNU General Public license for further details (see GNU General Public License).
# http://www.gnu.org/licenses/gpl.html

# Only Run this application once the instances have been built.

#### ========================================================= ####

if [ ! -f ./authcheck.sh ];then
    echo -e "You are not running the script from the proper directory.\nChange to the proper directory and try again."
    exit 1
        else
            source authcheck.sh
fi

ACTIONS="json/actions"
ACTIONNOTES="\nEXAMPLE : if the Naming convention was \"build1\" I would enter \"build1\"\nThe script will perform the actions all instances from the build series.\n"

if [ ! -d "$ACTIONS" ];then
    mkdir -p "$ACTIONS"
fi

echo -e "\nWhat would you like to do?\nRemember this effects the entire Cluster.\n"
echo -e "You can :\n- reboot :\t\"Reboots an Entire Cluster\"\n- resize :\t\"Resizes an Entire Cluster\"\n- confirm :\t\"Confirms the Resize of an Entire Cluster\"\n- revert :\t\"Reverts the Resize of an Entire Cluster\"\n- masterpw :\t\"Changes the Master Password for an Entire Cluster\""
read -p "Please Enter your Command : " OPTIONS

if [ -z "$OPTIONS" ];then 
echo "Processing Command."

# Reboot the Entire Cluster
elif [ "$OPTIONS" == "reboot" ];then
echo "Rebooting the entire Cluster" 
# Name of Build

        echo -e "\nEnter the Naming convention to reboot any instance in a build series"
        echo -e "$ACTIONNOTES"
        read -p "Naming Convention used for the series : " BUILDNAME

    SERIES="logs/urllist-$BUILDNAME.log"
    if [ -f "$SERIES" ];then
        echo "Rebooting Series $SERIES"
        cat $SERIES | $TIME parallel --retries 3 -k -j0 -X "curl -s -X POST -H \"Content-type: application/json\" -T \"$ACTIONS/HARD-REBOOT.json\" -H \"X-Auth-Token: $TOKEN\" {}/action"
        REST;
            else
                echo -e "\nFailed to find the build Series : $BUILDNAME\nIf you specify the correct build series we will be happy to reboot it.\n"
                exit 1
    fi

# resize the Entire Cluster
elif [ "$OPTIONS" == "resize" ];then
echo "Resizing the entire Cluster"

# Name of Build
    echo -e "\nEnter the Naming convention to resize all instances in a build series"
    echo -e "$ACTIONNOTES"
    read -p "Naming Convention used for the series : " BUILDNAME
    echo -e "\nResize Options :\n- 2 =\t512MB\n- 3 =\t1GB\n- 4 =\t2GB\n- 5 =\t4GB\n- 6 =\t8GB\n- 7 =\t15GB\n- 8 =\t30GB\n"
    read -p "Size you would like to rezize the series to : " RESIZEOPTION
    if [[ ! "$RESIZEOPTION" =~ [2-8] ]];then 
        echo -e "\nYou failed to enter the proper value, so I quit\n"
        exit 1
    fi
    echo "{ \"resize\" : { \"flavorRef\" : \"$RESIZEOPTION\" }}" > $ACTIONS/$BUILDNAME-RESIZE.json

    SERIES="logs/urllist-$BUILDNAME.log"
    if [ -f "$SERIES" ];then
        echo "Resizing Series $SERIES"
        cat $SERIES | $TIME parallel --retries 3 -k -j0 -X "curl -s -X POST -H \"Content-type: application/json\" -T \"$ACTIONS/$BUILDNAME-RESIZE.json\" -H \"X-Auth-Token: $TOKEN\" {}/action"
        rm $ACTIONS/$BUILDNAME-RESIZE.json
        REST;
            else
                echo -e "\nFailed to find the build Series : $BUILDNAME\nIf you specify the correct build series we will be happy to reboot it.\n"
                rm $ACTIONS/$BUILDNAME-RESIZE.json
                exit 1
    fi

# Confirm the resize the Entire Cluster
elif [ "$OPTIONS" == "confirm" ];then
echo "Resizing the entire Cluster"

# Name of Build
    echo -e "\nEnter the Naming convention to Confirm the resize of all instances in a build series"
    echo -e "$ACTIONNOTES"
    read -p "Naming Convention used for the series : " BUILDNAME

    SERIES="logs/urllist-$BUILDNAME.log"
    if [ -f "$SERIES" ];then
        echo "Confirming Resize of $SERIES series" 
        cat $SERIES | $TIME parallel --retries 3 -k -j0 -X "curl -s -X POST -H \"Content-type: application/json\" -T \"$ACTIONS/CONFIRM-RESIZE.json\" -H \"X-Auth-Token: $TOKEN\" {}/action"
        REST;
            else
                echo -e "\nFailed to find the build Series : $BUILDNAME\nIf you specify the correct build series we will be happy to reboot it.\n"
                exit 1
    fi

# Revert the resize the Entire Cluster
elif [ "$OPTIONS" == "revert" ];then

# Name of Build
    echo -e "\nEnter the Naming convention to Revert the resize of all instances in a build series"
    echo -e "$ACTIONNOTES"
    read -p "Naming Convention used for the series : " BUILDNAME

    SERIES="logs/urllist-$BUILDNAME.log"
    if [ -f "$SERIES" ];then
        echo "Reverting the Resize of $BUILDNAME series" 
        cat $SERIES | $TIME parallel --retries 3 -k -j0 -X "curl -s -X POST -H \"Content-type: application/json\" -T \"$ACTIONS/REVERT-RESIZE.json\" -H \"X-Auth-Token: $TOKEN\" {}/action"
        REST;
            else
                echo -e "\nFailed to find the build Series : $BUILDNAME\nIf you specify the correct build series we will be happy to reboot it.\n"
                exit 1
    fi
    
        else 
            echo -e "\nFound Nothing to do... So I quit\n"
            exit 1
fi

# Change the Master Password for the Entire Cluster
elif [ "$OPTIONS" == "masterpw" ];then
echo "Reset Master Password on All Instances within a Build Series."

# Name of Build
    echo -e "\nEnter the Naming convention for the series to change the master password on"
    echo -e "$ACTIONNOTES"
    read -p "Naming Convention used for the series : " BUILDNAME
    read -p "Enter Your New Password : " NEWPW
    if [ -z "$NEWPW" ];then 
        echo -e "\nYou failed to enter A new Password, so I quit\n"
        exit 1
    fi
    echo "{ \"changePassword\" : { \"adminPass\" : \"$RESIZEOPTION\" }}" > $ACTIONS/$BUILDNAME-PASSWORDRESET.json

    SERIES="logs/urllist-$BUILDNAME.log"
    if [ -f "$SERIES" ];then
        echo "Resetting Passwords on $SERIES"
        cat $SERIES | $TIME parallel --retries 3 -k -j0 -X "curl -s -X POST -H \"Content-type: application/json\" -T \"$ACTIONS/$BUILDNAME-PASSWORDRESET.json\" -H \"X-Auth-Token: $TOKEN\" {}/action"
        $ACTIONS/$BUILDNAME-PASSWORDRESET.json
        REST;
            else
                echo -e "\nFailed to find the build Series : $BUILDNAME\nIf you specify the correct build series we will be happy to reboot it.\n"
                rm $ACTIONS/$BUILDNAME-PASSWORDRESET.json
                exit 1
    fi
QUIT
