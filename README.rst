Mass Build Application
######################
:date: 2012-09-20 05:54
:tags: All, rackspace, build, mass, deployment, api
:category: linux 

Build a lot of Cloud Servers at once
====================================

If you have found yourself in a situation where you needed to build a bunch of Cloud Servers, and you needed that done in multiple data centers all at the same time, this is the application that you have been looking for. This system uses the Next Generation Rackspace Open Cloud to deploy as many instances at a time as your API settings allow.  

Prerequisites :
  * Python => 2.6 but < 3.0
  * Python Module "simplejson"
  * GNU/Core Utilities 
  * curl
  + This repository comes with a statically compiled version of the binary "parallel" which includes it's dependencies. 
  
The Process by which this application works is simple. All you have to do is Literally fill in the blanks. If you are not wanting to fill in the questions every time you do anything you can fill in the details you would like to be static in the "massinit.cfg" file. This will stream line the operation of the scripts.

The core function of this repository is to build instances. 

Functions of the scripts :
  * Building Multiple Instances
    * Can build in Segregated Data Centers or Multiple (Only US)
  * Get all IPv4 addresses for all Instance Built as a Series
  * Reboot All Instances Built as a Series
  * Resize All Instances Built as a Series 
  * Delete All Instances Built as a Series
    * Timed Deletion of Instances (Only If Master Stays On-line)


Script Definitions :
  authcheck.sh   : This script was created to authenticate a users credentials against the Rackspace API based on the location the users account was creaeted in. 
  
  massactions.sh : This script is a CORE set of actions that the Mass Build Application is capable of.  In order to use this script you will first have to build a series (cluster) of instances using the massbuild.sh script.
  
  massbuild.sh   : This script is for building a number of instance.  At Build time the script generates a json directory based on the build name and saves all of the used json files for easy rebuild if needed. It also creates a one line script in the same json directory allowing for building another instance from a single JSON file as needed. If a TTL is set in the "massinit.cfg" file this script will also set an "at" function on the host system for the deletion of the built instances as well as create a script in the "deleter" directory based on the build name for easy removal of the instances.
  
  massdelete.sh  : This script is for deleting a build series. The script uses the build name to determine the Servers URL and UUID based on information found within the logs. 
  
  massgetip.sh   : This script will pull all Public IPv4 addresses on a Build Series.  This information is obtained though the use of the logs when the instances were built.
  
  massinit.cfg   : This is a Configuration file used across all scripts.  In the configuration file you can specify anything any variable that you would like to be hard coded.  You can leave any variable blank, the scripts will ask for the proper information if its needed.

Available Options in the "massinit.cfg"
  * USERNAME - This is your Rackspace Cloud Username for the Cloud Account
  * APIKEY - This is your Rackspace Cloud API Key found in the Cloud Control Panel 
  * LOCAL - This is the Country that your account resides in
  * DC - What Data Center are you using. Options are ord, dfw, and lon. You can use "multi" to build in both DFW and ORD
  * NUMSERVERS - How Many Instances do you want to build
  * BUILDNAME - What is the name of the Build Series
  * FLAVORID - What Size Instance are you Building, valid choices are 2 - 8, see README/FLAVORIDS.txt for a breakdown of available Flavors
  * IMAGEID - What is the Image ID Number that you are building from, see README/IMAGEIDS.txt for a list of available Flavors
  * PASSWORD - What is the root password that you are setting for your instances
  * SSHUSERKEY - SSH Public Key for Instance Access, this is a key that will be injected upon build of the instance
  * TTL - The Time the server will exist in Minutes. This function is best used when the Master Build Server remains Active. This function is only used by the scripts if you have some value in the this variable.  If you set a TTL the time will be set in Minutes.
  

Disclaimer :
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

  See "README/LICENSE.txt" for full disclosure of the license associated with this product. Or goto http://www.gnu.org/licenses/