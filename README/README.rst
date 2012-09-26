Mass Deployment, VIA The Rackspace API
######################################
:date: 2012-09-20 05:54
:tags: All, rackspace, build, mass, deployment, api
:category: linux 

The Rackspace API is capable of a lot of things with it's primary function being to allow users of the Rackspace Cloud to develop Applications around a Cloud Based ecosystem and Infrastructure.  With the implementation of the Rackspace Open Cloud, the API was completely rewritten using the Openstack API standard. These changes added redundancies, functionality, and more scalability.

What Rackspace API is Capable of :
  While remaining within the Rate limits provided by the standard users API, I stress tested the CORE cloud API within the Rackspace Next Generation Cloud powered by Openstack. Using the mass Build application I was able to spin up 500 Instances, 250 in Chicago and 250 in Dallas. Total time for all instance to become active was just under 14 minutes.
  
  The reason that the test was limited to 500 Instances was related to my own accounts API Settings. Additionally the rate limit limitations required me to stagger the build process in waves of 100 every 65 Seconds.  To accommodate these restrictions I setup the configuration file for the Mass Build Application, everything was statically set except the build name which I set as "$1". This setup allowed me to specify the build name via the command line as an argument. To build all 500 instances the "multi" data center flag was set and I used a "loop" incrementing the build name with the sequence number.  

  **Here is the loop used for the build :**

  .. code-block:: bash

     for BUILD in {1..5}; do ./massbuild.sh build$BUILD; done

API Actions Results :
  The total time for the "loop" to run was 5 minutes 25 seconds, which resulted in 500 Instances in Build Status. The average build time was just under 6 minutes and out of the 500 building instances, 1 went into error mode. The post build results yielded all 499 instances in an active state in just under 14 minutes.

Stats from the Build :
  * Fastest Build time

    :real: 3m49.589s
    :sys: 0m0.156s

  * Slowest Build time

    :real: 10m58.424s
    :sys: 0m1.012s

  The single Instance that failed to build was handled with ease because the Mass Build application saves all of the JSON files used in the build process. Additionally, the application creates an easy script for building any particular instance using the saved JSON files.

Limitations : 
  1. The Build process that I used was building stock instances from Rackspace Provided Images. The "multi" data center function requires that the Image UUID be the same in both data centers. This limitation would make it impossible to spin up Instances based on a Snapshot Image in both data centers. However you could simply do 2 builds one in each datacenter.  To accommodate this, simply leave the imageid variable blank in the "massinit.cfg" file which will force the application to ask you what image you want to build from. You could also change this argument to a command line variable like "$1", as I had done in my 500 Instance Build.
  
  2. All Accounts have API limitations in place, these limitations have been setup by the Rackspace and can only be changed via written request in a ticket to Rackspace Support. These restraints were what I was working with as I built requiring me to build no more than 100 instances per minute and no more than 1000 Instances in a day. You should note that the rate limits are data center specific, so they are very forgiving on massive deployments though may require some ingenuity. 

     The base limitations are :

     ======= ================ ======= ========
     Stock API Limits
     -----------------------------------------
      Verb        URI         Value    Unit  
     ======= ================ ======= ========
       GET          *           100    MINUTE 
       GET    /os-networksv2     0     MINUTE 
       GET       /servers       1000    DAY   
       POST         *           100    MINUTE 
       POST   /os-networksv2     0      DAY   
       POST      /servers       1000    DAY   
     ======= ================ ======= ========


  3. Hard set API limits for the consumption of Resources have also been set. During my build testing I had the API Absolute Limits increased which allowed me to have 500 Instances in two data centers, as well as consume 1TB of RAM. However, these limits make building a lot of instances consuming lots of resources impossible without first contacting support and planning the deployment.  Here are stock limits :

     ========================== =======
     Stock Absolute API Limits
     ----------------------------------
               Name             Value 
     ========================== =======   
           maxImageMeta           20  
          maxPersonality          5   
        maxPersonalitySize       10240 
          maxServerMeta           20  
          maxTotalCores           -1  
       maxTotalFloatingIps        5   
        maxTotalInstances         100  
         maxTotalKeypairs         100  
      maxTotalPrivateNetworks     0   
         maxTotalRAMSize         66560 
      maxTotalVolumeGigabytes     -1  
         maxTotalVolumes          0   
          totalCoresUsed          0   
         totalInstancesUsed       0   
         totalKeyPairsUsed        0   
      totalPrivateNetworksUsed    0   
           totalRAMUsed           0   
      totalSecurityGroupsUsed     0   
      totalVolumeGigabytesUsed    0   
         totalVolumesUsed         0   
     ========================== =======


--------

Conclusion : 
  The Rackspace API allowed me to deploy a lot of instances fast and efficiently.  While my deployment was a test case, a real world deployment may be based on a "GOLD" image and or an image production ready instance. The Rackspace API coupled with the an efficient means by which an administrator can command and control the cloud infrastructure, such as Mass Build Application or the Python-Novaclient, users can easily leverage the API producing a lot of instances simultaneously and pragmatically. On top of building new instances the API provides functions to easily remove, resize, and reboot instances. When using something like the Mass Build Application the API can be used to perform many of the available actions on Instances all at scale. The Openstack API, which is powering the Rackspace Cloud is a full featured API which has the ability to be utilized to perform any task within the scope, limits and restrictions set by the Openstack provider.

