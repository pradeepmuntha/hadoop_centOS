# Hadoop Containers with CDH-5.7.0 and JDK 1.8.0_66
I did run into multiple situations in the past where i wanted to run tests on hadoop cluster running on multiple nodes using different JDK and Hadoop versions. I had to go through painful process of spinning up VM's with some Linux OS, Download different versions of s/w needed, setup environment and basic config files before i could actually test what i wanted to in Hadoop layer. If you are one such guy,
looking for a quick hadoop 3 node cluster setup to run few tests, then you are in right place.

All you have to do is run couple of commands mentioned below which will pull docker image from pradeepmuntha/hadoop_centos_autobuild repository which is a UFS layered image running CentOS 6.7 with CDH-5.7.0 and Hadoop version 2.6.0 with JDK 1.8.0_66. "startup.sh" script included in this GIT will help you spin up a basic non HA cluster with 1 NN and 2 Datanodes along with 1 RM and 2 Node Managers. But one can always use docker image from hadoop_centos_autobuild repo and spin up any number of datanodes/NodeManagers needed.

I am yet to add functionalities needed to spin up cluster in HA mode along with support for other Bigdata ecosystem projects.This will also be re-factored in a better way in coming days.


* *Note*: There are many documents and blogs in internet which discusses about how to install docker engine on Linux/Ubuntu box and setup a non-root user account to run docker so i assume you have already installed docker software on host machine (which is pretty simple and straight).  


##Pre-Requisite:

Before startup.sh script is executed, docker software should already be installed with services running on host (Please refer articles on internet as s/w installation is fairly simple) and directory structure needed to persist namenode fsimage with datanode blocks and logs onto a more permanent storage which do not get destroyed along with containers as they are ephemeral. Below pre-requisite commands should be executed as "root" user. (This is needed to avoid user permissions differences between docker host exporting dicrectories as volumes and containers. There are other ways which can be used to ensure ownership on exported volumes remain same on host and containers but below is easy way).

```bash
# export VOLUMEDIR="/home/docker/data"   (This directory can be any path with ample storage space to hold datanode blocks).
# mkdir -p $VOLUMEDIR/master/data $VOLUMEDIR/slave1/data-{1,2} $VOLUMEDIR/slave2/data-{1,2} $VOLUMEDIR/logs/
# chmod 1777 $VOLUMEDIR/master/data $VOLUMEDIR/slave1/data-{1,2} $VOLUMEDIR/slave2/data-{1,2} $VOLUMEDIR/logs
```


-----------------------------------------------------------------------------------------------------------------------------------------


* *Note*: Commands from here can be executed as normal user that is part of docker group. Ther are many documents and blogs in internet that discusses how to add a normal user to docker group so all docker commands can be executed as non-root users (This should take less than a minute or two).For this example i have a user account "docker" on my local box that is part of "docker" group.

* *Start Docker Containers and Services*:

```bash
$ git clone https://github.com/pradeepmuntha/hadoop_centOS
$ hadoop_centOS/startup.sh "/home/docker/data" start  (Directory used should be same as $VOLUMEDIR)
```

This command should do all the action in background and start three containers (1 Master and 2 slave) with necessary services. Running containers can be verified using command

```bash
$ docker ps
$ docker exec -t -u hdfs master /usr/local/hadoop/bin/hdfs dfs -put /etc/redhat-release /
$ docker exec -t -u hdfs master /usr/local/hadoop/bin/hdfs dfs -ls /
```
We can also attach outselves with the container bash shell and work on container as on Normal Linux host using

```bash
$docker attach master
```
You will be dropped to "master" container hdfs user shell.

Note: TO EXIT FROM CONTAINER, DO NOT TYPE "exit" OR "Ctrl+d" AS IT WILL SHUTDOWN CONTAINER. Use key sequence Ctrl+p Ctrl+q
Hadoop and JDK are deployed under /usr/local in containers.


* *Start services only*: Assuming containers are already running

```bash
$ hadoop_centOS/startup.sh "/home/docker/data" start_services
```

* *Stop Services only*: This will only stop services. Containers will continue to be up and available for services startup again.

```bash
$ hadoop_centOS/startup.sh "/home/docker/data" stop_services
```

* *Stop both services and Containers*:

```bash
$ hadoop_centOS/startup.sh "/home/docker/data" stop
```

* *Destroy containers and delete all directories and logs*:

```bash
$ hadoop_centOS/startup.sh "/home/docker/data" destroy
```

Handy for quick cleanup of everything before starting over from directories creation as root user and "Start Docker Containers and Services" section.  


* *Note*: When executed first time, image download will take about 5 to 10 mintues depending on internet bandwidth as container image has Hadoop and JDK s/w pre-installed. Further executions of startup.sh do not download entire image again from docker registry as its present locally. At completion of startup.sh you should have three containers running one serving as Namenode and other two as datanodes. Hadoop software is installed in path */usr/local/hadoop*.

* *Moving in and out of Docker containers and some useful commands*:

```bash
$ docker ps   (To Display list of contianers running on host)
$ docker attach master (Shell access to hdfs user account on namenode. To exit container DO NOT TYPE EXIT OR Ctrl + D as it will shut the container down. Instead use Ctrl + p + q combination to return back to linux host shell).
$ docker images (To list images present on host running docker engine)
$ docker exec -u hdfs master "ps aux"
```

Namenode Health page can be accessed from browser of Linux host running docker engine on port 50070 and RM page on port 8088. If hostname of Linux host running docker software is docker-host then NN health page would be accessible from http://docker-host:50070 from browser and RM page from http://docker-host:8088

WIP to update configurations and S/W locations needed to bring up HBase layer. Expecting to complete pretty soon :).
