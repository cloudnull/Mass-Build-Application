#!/bin/bash
# - title        : MassBuild for Cloud Servers
# - description  : This script will get the IP Addresses for a built series
# - License      : GPLv3+
# - author       : Kevin Carter
# - date         : 2011-09-20
# - version      : 1.0    
# - usage        : bash massgetip.sh
# - notes        : This is a get ip Script
# - bash_version : >= 3.2.48(1)-release

# This software has no warranty, it is provided “as is”. It is your responsibility 
# to validate the behavior of the routines and its accuracy using the code provided.  
# Consult the GNU General Public license for further details (see GNU General Public License).
# http://www.gnu.org/licenses/gpl.html

# Only Run this application once the instances have been built to the point they have Public IP addresses.

#### ========================================================= ####

if [ ! -f ./authcheck.sh ];then
    echo -e "You are not running the script from the proper directory.\nChange to the proper directory and try again."
    exit 1
        else
            source authcheck.sh
fi

BUILDNAME="$1"
# Name of Build
if [ -z "$BUILDNAME" ];then
echo -e "\nEnter the General Naming convention, the system will\npull all IP addresses for all instances built.\n\nEXAMPLE : if the Naming convention was \"build1\" I would enter just \"build\"\nThe script will pull eveything from the build series.\n"
read -p "Naming Convention used for the series : " BUILDNAME
fi

# Make the Get IP address Directory
if [ ! -d getip ];then 
    mkdir getip
fi

# Set the IPADDRESS Variable 
IPADDRESSES="getip/ipaddress-$BUILDNAME.txt"

# Remove the IPADDRESS File it it already exists 
if [ -f $IPADDRESSES ];then
    rm $IPADDRESSES;
fi

# Get the instance IP addresses 
for SERIES in $(find logs/ -name urllist-$BUILDNAME*); 
    do
        cat $SERIES | time parallel --retries 3 -k -j0 -X "curl -s -X GET -H \"X-Auth-Token: $TOKEN\" {} | python -m json.tool | grep -A10 'public' | grep -B1 'version\": 4' | awk -F '\"' '/addr/ {print \$4}'" >> $IPADDRESSES;
            REST;
done

QUIT
