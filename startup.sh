#!/bin/bash

HADOOP_PREFIX="/usr/local/hadoop"

NH=$1

if [ "$NH" != 3 ]
then
	echo "Currently we only support 3 node cluster with one namenode and 2 datanodes. Additional support will be extended soon"
	exit 1
fi

docker stop master1 slave1 slave2
docker rm master1 slave1 slave2
docker pull pradeepmuntha/hadoop_centos_autobuild:latest
docker run -tid --name master1 --hostname master1 -p 50070:50070 --add-host=master1:172.17.0.2 --add-host=slave2:172.17.0.4 --add-host=slave1:172.17.0.3 pradeepmuntha/hadoop_centos_autobuild:latest

for i in `seq 1 $(($NH-1))`
do
	docker run -tid --name slave$i --hostname slave$i --add-host=master1:172.17.0.2 --add-host=slave2:172.17.0.4 --add-host=slave1:172.17.0.3 pradeepmuntha/hadoop_centos_autobuild:latest
	if [ $? -ne 0 ]
	then
		echo "Error during startup of container slave-$i"
		exit 2
	fi
done

docker exec master1 $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode

for i in slave1 slave2
do
	docker exec $i $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
done
