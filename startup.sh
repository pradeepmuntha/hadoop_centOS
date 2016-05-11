#!/bin/bash

HADOOP_PREFIX="/usr/local/hadoop"
VOL=$1
ACT=$2

if [ -z $VOL ] || [ ! -d $VOL ]
then 
	echo "Volume Directory not mentioned as fist argument or directory does not exist. Please ensure pre-requisite commands mentioned in Readme section of GIT are executed as root user"
	exit 1
fi


case $ACT in

start)
	docker pull pradeepmuntha/hadoop_centos_autobuild:latest
	CNT=`docker network ls | grep "custom_bridge" | grep -v grep |wc -l`
	if [ "$CNT" -ne 0 ]
	then
        	echo "Docket network \"custom_bridge\" network already exists on the system so not re-creating it !!!!. Execute 'docker network ls' command to check list of docker networks on host" 
	else
        	docker network create -d bridge --label custom_bridge --subnet=172.98.0.1/24 --gateway 172.98.0.1 --opt "com.docker.network.bridge.enable_ip_masquerade"="true" --opt "com.docker.network.bridge.enable_icc"="true" --opt "com.docker.network.bridge.host_binding_ipv4"="0.0.0.0" --opt "com.docker.network.mtu"="1500" --opt "com.docker.network.bridge.name"="docker-custom-bridge-0" custom_bridge

	fi

#Master Node Commands
	docker run -tdi  --user hdfs --name master --hostname master1 --net custom_bridge --ip 172.98.0.2 -p 50070:50070 -p 8088:8088 --add-host=master1:172.98.0.2 --add-host=slave2:172.98.0.4 --add-host=slave1:172.98.0.3 -v $VOL/master/data:/data -v $VOL/logs:$HADOOP_PREFIX/logs hadoop:mod
	docker exec -u hdfs master $HADOOP_PREFIX/bin/hdfs namenode -format
	docker exec -u hdfs master $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode

#Slave Containers Creation
	docker run -tdi  --user hdfs --name slave1 --hostname slave1 --net custom_bridge --ip 172.98.0.3 --add-host=master1:172.98.0.2 --add-host=slave2:172.98.0.4 --add-host=slave1:172.98.0.3 -v $VOL/slave1/data-1:/data-1 -v $VOL/slave1/data-2:/data-2 -v $VOL/logs:$HADOOP_PREFIX/logs hadoop:mod
	docker run -tdi  --user hdfs --name slave2 --hostname slave2  --net custom_bridge --ip 172.98.0.4 --add-host=master1:172.98.0.2 --add-host=slave2:172.98.0.4 --add-host=slave1:172.98.0.3 -v $VOL/slave2/data-1:/data-1 -v $VOL/slave2/data-2:/data-2 -v $VOL/logs:$HADOOP_PREFIX/logs hadoop:mod

#Slave perm fix and service startup
	docker exec -u hdfs slave1 mkdir /data-{1,2}/hdfs
	docker exec -u hdfs slave2 mkdir /data-{1,2}/hdfs
	docker exec -u hdfs slave1 $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
	docker exec -u hdfs slave2 $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
#Yarn layer startup
	docker exec -u hdfs master $HADOOP_PREFIX/sbin/yarn-daemon.sh start resourcemanager
	docker exec -u hdfs slave1 $HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager
	docker exec -u hdfs slave2 $HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager
	;;

start_services)
	docker exec -u hdfs master $HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
	docker exec -u hdfs slave1 $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
        docker exec -u hdfs slave2 $HADOOP_PREFIX/sbin/hadoop-daemon.sh start datanode
	docker exec -u hdfs master $HADOOP_PREFIX/sbin/yarn-daemon.sh start resourcemanager
	docker exec -u hdfs slave1 $HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager
	docker exec -u hdfs slave2 $HADOOP_PREFIX/sbin/yarn-daemon.sh start nodemanager
	;;

stop_services)
	docker exec -u hdfs slave2 $HADOOP_PREFIX/sbin/hadoop-daemon.sh stop datanode
	docker exec -u hdfs slave1 $HADOOP_PREFIX/sbin/hadoop-daemon.sh stop datanode
	docker exec -u hdfs master $HADOOP_PREFIX/sbin/hadoop-daemon.sh stop namenode
	docker exec -u hdfs master $HADOOP_PREFIX/sbin/yarn-daemon.sh stop resourcemanager 
	docker exec -u hdfs slave1 $HADOOP_PREFIX/sbin/yarn-daemon.sh stop nodemanager 
	docker exec -u hdfs slave2 $HADOOP_PREFIX/sbin/yarn-daemon.sh stop nodemanager 
	;;

stop)
	docker exec -u hdfs slave2 $HADOOP_PREFIX/sbin/hadoop-daemon.sh stop datanode
        docker exec -u hdfs slave1 $HADOOP_PREFIX/sbin/hadoop-daemon.sh stop datanode
        docker exec -u hdfs master $HADOOP_PREFIX/sbin/hadoop-daemon.sh stop namenode
	docker exec -u hdfs master $HADOOP_PREFIX/sbin/yarn-daemon.sh stop resourcemanager  
	docker exec -u hdfs slave1 $HADOOP_PREFIX/sbin/yarn-daemon.sh stop nodemanager 
	docker exec -u hdfs slave2 $HADOOP_PREFIX/sbin/yarn-daemon.sh stop nodemanager 
	docker stop master slave1 slave2 
	docker rm master slave1 slave2
	;;

destroy)
	read -p "This will delete data blocks and fsimage that was persisted on docker volume. Do you want to continue [y/n]:  " input
	if [ "$input" == 'y' ]
	then
		echo "Execute command # rm -rf $VOL/master/data/* $VOL/slave1/data-{1,2}/* $VOL/slave2/data-{1,2}/* $VOL/logs/* as root user to cleanup diretories created by hdfs user account on share volumes"
	fi
	;;
*)	
	echo "Wrong command usage. Supported commands are start, stop and destroy"
	;;
esac
