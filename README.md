# Hadoop Containers with CDH-5.7.0 and JDK 1.8.0_66
I did run into multiple situations in the past where i wanted to run tests on hadoop cluster running on multiple nodes using different JDK and Hadoop versions. I had to go through painful process of spinning up VM's with some Linux OS, Download different versions of s/w needed, setup environment and basic config files before i could actually test what i wanted to in Hadoop layer. If you are one such guy,
looking for a quick hadoop 3 node cluster setup to run few tests, then you are in right place.

All you have to do is run couple of commands mentioned below which will pull docker image from pradeepmuntha/hadoop_centos_autobuild repository which is a UFS layered image running CentOS 6.7 with CDH-5.7.0 and Hadoop version 2.6.0 with JDK 1.8.0_66. "startup.sh" script included in this GIT will help you spin up a basic non HA cluster with one NN and two datanodes. But one can always use docker image from hadoop_centos_autobuild repo and spin up any number of datanodes needed.

I am yet to add functionalities needed to spin up cluster in HA mode along with support for other Bigdata ecosystem projects.This will also be re-factored in a better way in coming days.


* *Note*: There are many documents and blogs in internet which discusses about how to install docker engine on Linux/Ubuntu box and setup a non-root user account to run docker so i assume you have already installed docker software on host machine (which is pretty simple and straight).  


##Pre-Requisite:

Before startup.sh script is executed, directory structure is needed to persist both namenode fsimage and datanode blocks and logs onto a more permanent storage which do not get destroyed along with containers as they are ephemeral. These pre-requisite commands should be executed as "root" user. (This is needed to avoid user permissions differences between docker host exporting dicrectories as volumes and containers. There are other ways which can be used to ensure ownership on exported volumes remain same on host and containers but below is easy way).

```bash
# export VOLUMEDIR="/home/docker/data"   (This directory can be any path with ample storage space to hold datanode blocks).
# mkdir -p $VOLUMEDIR/master/data $VOLUMEDIR/slave1/data-{1,2} $VOLUMEDIR/slave2/data-{1,2} $VOLUMEDIR/logs/
# chmod 1777 $VOLUMEDIR/master/data $VOLUMEDIR/slave1/data-{1,2} $VOLUMEDIR/slave2/data-{1,2} $VOLUMEDIR/logs
```

* *Note*: Commands from here can be executed as normal user that is part of docker group. Ther are many documents and blogs in internet that discusses how to add a normal user to docker group so all docker commands can be executed as non-root users (This should take less than a minute or two).For this example i have a user account "docker" on my local box that is part of "docker" group.

```bash
$ git clone https://github.com/pradeepmuntha/hadoop_centOS
$ hadoop_centOS/startup.sh "/home/docker/data" (This should be same directory as VOLUMEDIR)
```

This should pull all images needed, install hadoop and JDK, spin up containers and start services needed to bring up Hadoop Layer.
WIP to update configurations and S/W locations needed to bring up Yarn and HBase layer. Expecting to complete pretty soon :).
