#!/bin/bash
# - title        : MassDelete Post MassBuild for Cloud Servers
# - description  : This script will assist in Deleting a lot of Cloud Servers From a Build Series
# - License      : GPLv3+
# - author       : Kevin Carter
# - date         : 2011-09-20
# - version      : 1.0    
# - usage        : bash massdelete.sh
# - notes        : This is a Cloud Deletion Script
# - bash_version : >= 3.2.48(1)-release

# This software has no warranty, it is provided “as is”. It is your responsibility 
# to validate the behavior of the routines and its accuracy using the code provided.  
# Consult the GNU General Public license for further details (see GNU General Public License).
# http://www.gnu.org/licenses/gpl.html

#### ========================================================= ####

if [ ! -f ./authcheck.sh ];then
    echo -e "You are not running the script from the proper directory.\nChange to the proper directory and try again."
    exit 1
        else
            source authcheck.sh
fi

# Name of Build
BUILDNAME=$1
if [ -z "$BUILDNAME" ];then
    read -p "Naming Convention used for deployment : " BUILDNAME
fi

# Set the Delete Variable 
DELETEACTION="logs/massdelete-$BUILDNAME.log"

# Remove the Instance
if [ -f $DELETEACTION ];then
    rm $DELETEACTION;
fi

# Get the instance IP addresses 
cat logs/urllist-$BUILDNAME.log | parallel --retries 3 -k -j0 -X "curl -s -X DELETE -H \"X-Auth-Token: $TOKEN\" {}" >> $DELETEACTION;

REST

QUIT
