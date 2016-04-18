# hadoop
If you are looking for a quick hadoop 3 node cluster setup to run few tests, then you are in right place. All you have to do is execute startup.sh script present in this repo which will pull docker image from pradeepmuntha/hadoop_centos_autobuild repository which is a layered image running CentOS 6.7 with CDH-5.7.0 and Hadoop version 2.6.0 with one namenode and two datanodes. 

I am yet to add functionalities needed to spin more than two datanodes and master nodes along with support for other Bigdata ecosystem projects. Startup.sh is right now hardcoded for quick spin-up of mini hadoop cluster. This will also be re-factored in a better way in coming days.


Usage:

$ ./startup.sh 3 

Right now script accepts only integer 3 as argument to spin up three containers. Upon completion of this script execution, Namenode health page is accessible directly from local system's browser on port 50070.
