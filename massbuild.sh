#!/bin/bash
# - title        : MassBuild for Cloud Servers
# - description  : This script will assist in Creating a lot of Cloud Servers
# - License      : GPLv3+
# - author       : Kevin Carter
# - date         : 2011-09-20
# - version      : 1.0    
# - usage        : bash massbuild.sh
# - notes        : This is a Cloud Build Script
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

# Number of Servers
if [ -z "$NUMSERVERS" ];then
    read -p "Number Of Instances : " NUMSERVERS
fi

# Name of Servers
if [ -z "$BUILDNAME" ];then
    read -p "Naming Convention of Instances : " BUILDNAME
fi

# Image ID Number
if [ -z "$IMAGEID" ];then
    read -p "Image ID Number : " IMAGEID
fi

# Set a ROOT password for build.
if [ -z "$PASSWORD" ];then
  read -p "Enter the ROOT password for the instances : " PASSWORDTEMP1
  read -p "Please enter it again : " PASSWORDTEMP2
  if [ ! "$PASSWORDTEMP1" == "$PASSWORDTEMP2" ];then 
      echo "You Failed to enter the same password twice. Try Again"
      exit 1 
      else
          PASSWORD="$PASSWORDTEMP1"
  fi
fi

# FLAVOR ID Number
if [ -z "$FLAVORID" ];then
    read -p "Flavor ID Number : " FLAVORID
fi

# The working directory name 
    WORKINGTEMP="$(pwd)/json/$BUILDNAME-json"

if [ ! -d ./$WORKINGTEMP ];then
    mkdir -p $WORKINGTEMP
fi

echo -e "\nBuilding JSON Files, A record of the build files will be saved in : $WORKINGTEMP\n"

if [ -z "$SSHUSERKEY" ];then
    # Building the JSON Files for this Operation
    for JSONFILE in $(eval echo {1..$NUMSERVERS}); do echo "{\"server\" : {\"name\" : \"$BUILDNAME-ID$JSONFILE\", \"imageRef\" : \"$IMAGEID\", \"flavorRef\" : \"$FLAVORID\", \"adminPass\": \"$PASSWORD\", \"OS-DCF:diskConfig\" : \"AUTO\", \"metadata\" : { \"My Server Name\" : \"$BUILDNAME\" }, \"personality\" : [ { \"path\" : \"/root/.ssh/authorized_keys\", \"contents\" : \"$SSHKEY\" } ] }}" > $WORKINGTEMP/$BUILDNAME-ID$JSONFILE.json; done

        else
        SSHKEY=$(echo $SSHUSERKEY | base64 -w 0)

        # Building the JSON Files for this Operation
        for JSONFILE in $(eval echo {1..$NUMSERVERS}); do echo "{\"server\" : {\"name\" : \"$BUILDNAME-ID$JSONFILE\", \"imageRef\" : \"$IMAGEID\", \"flavorRef\" : \"$FLAVORID\", \"adminPass\": \"$PASSWORD\", \"OS-DCF:diskConfig\" : \"AUTO\", \"metadata\" : { \"My Server Name\" : \"$BUILDNAME\" }, \"personality\" : [ { \"path\" : \"/root/.ssh/authorized_keys\", \"contents\" : \"$SSHKEY\" } ] }}" > $WORKINGTEMP/$BUILDNAME-ID$JSONFILE.json; done
fi

# Building the Instances 
  echo -e "Building $NUMSERVERS Instance(s), This may be a minute\n"

# Check for UUID file
    if [ ! -d logs ];then
        mkdir logs
    fi

    if [ -f logs/$BUILDNAME.log ];then 
        rm logs/$BUILDNAME.log
    fi

# Paralled Build
if [ "$DC" == "multi" ];then
    seq 1 $NUMSERVERS | $TIME parallel --retries 3 -k -j0 -X "echo -n \"Server Build $BUILDNAME-ID{} -- \"; curl -s -X POST -H \"X-Auth-Token: $TOKEN\" -T \"$WORKINGTEMP/$BUILDNAME-ID{}.json\" -H \"Content-type: application/json\" $ORDSERVERSURL/servers; echo -e ' -- End Server ID{} \n'" >> logs/$BUILDNAME.log;
    
    echo -e "REPLACEME=\"\$1\";if [ ! -f \$REPLACEME ];then echo -e \"I failed to find the file you were wanting to rebuild from\"; exit 1; fi; curl -s -X POST -H \"X-Auth-Token: $TOKEN\" -T \"\$REPLACEME\" -H \"Content-type: application/json\" $ORDSERVERSURL/servers" > $WORKINGTEMP/ORD-QUICK-REBUILD.sh
    
    seq 1 $NUMSERVERS | $TIME parallel --retries 3 -k -j0 -X "echo -n \"Server Build $BUILDNAME-ID{} -- \"; curl -s -X POST -H \"X-Auth-Token: $TOKEN\" -T \"$WORKINGTEMP/$BUILDNAME-ID{}.json\" -H \"Content-type: application/json\" $DFWSERVERSURL/servers; echo -e ' -- End Server ID{} \n'" >> logs/$BUILDNAME.log;
    
    echo -e "REPLACEME=\"\$1\";if [ ! -f \$REPLACEME ];then echo -e \"I failed to find the file you were wanting to rebuild from\"; exit 1; fi; curl -s -X POST -H \"X-Auth-Token: $TOKEN\" -T \"\$REPLACEME\" -H \"Content-type: application/json\" $DFWSERVERSURL/servers" > $WORKINGTEMP/DFW-QUICK-REBUILD.sh
    
        else
            seq 1 $NUMSERVERS | $TIME parallel --retries 3 -k -j0 -X "echo -n \"Server Build $BUILDNAME-ID{} -- \"; curl -s -X POST -H \"X-Auth-Token: $TOKEN\" -T \"$WORKINGTEMP/$BUILDNAME-ID{}.json\" -H \"Content-type: application/json\" $SERVERSURL/servers; echo -e ' -- End Server ID{} \n'" >> logs/$BUILDNAME.log;
            
            echo -e "REPLACEME=\"\$1\";if [ ! -f \$REPLACEME ];then echo -e \"I failed to find the file you were wanting to rebuild from\"; exit 1; fi; curl -s -X POST -H \"X-Auth-Token: $TOKEN\" -T \"\$REPLACEME\" -H \"Content-type: application/json\" $SERVERSURL/servers" > $WORKINGTEMP/QUICK-REBUILD.sh
fi

# Finish Build Assignment 
  echo -e "\nThere is a log file that you can review for the build here : logs/$BUILDNAME.log"
  echo -e "\nAll JSON files for the build have been stored in \"$WORKINGTEMP\" in this direcotory,\nthere is a simple script that can assist in rebuilding a single instance from its JSON file if need be.\n"

# Log Passwords and present
  echo "$PASSWORD" > logs/$BUILDNAME-password.log
  echo -e "\nA root Password has been set for your new instances, The Password is : $PASSWORD\nYou can review the passwords in the build password log file at : logs/$BUILDNAME-password.log\n"

# Check for UUID file
    if [ -f logs/uuidlist-$BUILDNAME.log ];then 
        rm logs/uuidlist-$BUILDNAME.log
    fi

# generate a uuid list for all built instances
  awk -F '"' '/id/ {print $10}' logs/$BUILDNAME.log >> logs/uuidlist-$BUILDNAME.log
  awk -F '"' '/href/ {print $16}' logs/$BUILDNAME.log >> logs/urllist-$BUILDNAME.log
  
if [ "$(grep '"code": [3-5][0-9][0-9]' logs/$BUILDNAME.log)" ];then
  if [ "$(grep 'Invalid imageRef' logs/$BUILDNAME.log)" ];then
      echo -e "\n\033[1;35mThe Image you were attempting to build from was not available. Check the image ID number and try again.\033[0m\n"
      exit 1
  fi
    echo -e "\n\033[1;35mThere were errors found in the build process, please check the logs for more details.\033[0m\n"
fi

# Set for Deletion if TTL was specified 
if [ "$TTL" ];then

# Make the deleter Directory
    if [ ! -d deleter ];then 
        mkdir deleter
    fi
    
# Create a Delete script file
    echo "cd $(pwd); $(pwd)/massdelete.sh $BUILDNAME;" > $(pwd)/deleter/delete-$BUILDNAME.sh
    chmod +x $(pwd)/deleter/delete-$BUILDNAME.sh

# Set Delete
    if [ $(which at) ];then
        at now + $TTL minutes -f "$(pwd)/deleter/delete-$BUILDNAME.sh"
            else
                echo "The \"at\" command was not found. Timed Deletion will not work."
                echo "Please delete the the instances using the \"$(pwd)/deleter/delete-$BUILDNAME.sh\" script in $TTL Minutes."
    fi
fi
    REST
QUIT
