#!/bin/bash

HADOOP_PREFIX="/usr/local/hadoop"
VOL=$1
#NH=$1

if [ -z $VOL] || [ ! -d $VOL ]
then
	echo "Volume Directory not mentioned as fist argument or directory does not exist. Please ensure pre-requisite commands mentioned in Readme section of GIT are executed as root user"
	exit 1
fi

docker stop master slave1 slave2
docker rm master slave1 slave2
docker pull pradeepmuntha/hadoop_centos_autobuild:latest

#Master Node Commands
docker run -tdi --user hdfs --name master --hostname master1 -p 50070:50070 --add-host=master1:172.17.0.2 --add-host=slave2:172.17.0.4 --add-host=slave1:172.17.0.3 -v $VOL/master/data:/data -v $VOL/logs:$HADOOP_PREFIX/logs hadoop:mod
docker exec -u hdfs master $HADOOP_PREFIX/bin/hdfs namenode -format
docker exec -u hdfs master $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode

#Slave Containers Creation
docker run -tdi --user hdfs --name slave1 --hostname slave1 --add-host=master1:172.17.0.2 --add-host=slave2:172.17.0.4 --add-host=slave1:172.17.0.3 -v $VOL/slave1/data-1:/data-1 -v $VOL/slave1/data-2:/data-2 -v $VOL/logs:$HADOOP_PREFIX/logs hadoop:mod
docker run -tdi --user hdfs --name slave2 --hostname slave2 --add-host=master1:172.17.0.2 --add-host=slave2:172.17.0.4 --add-host=slave1:172.17.0.3 -v $VOL/slave2/data-1:/data-1 -v $VOL/slave2/data-2:/data-2 -v $VOL/logs:$HADOOP_PREFIX/logs hadoop:mod

#Slave perm fix and service startup
docker exec -u hdfs slave1 mkdir /data-{1,2}/hdfs
docker exec -u hdfs slave2 mkdir /data-{1,2}/hdfs
docker exec -u hdfs slave1 $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
docker exec -u hdfs slave2 $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
