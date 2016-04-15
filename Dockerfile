FROM pradeepmuntha/hadoop:latest
RUN yum install -y which tar sudo openssh-server openssh-clients rsync
ENV HADOOP_PREFIX /usr/local/hadoop
COPY hadoop/ /usr/local/
COPY java/ /usr/lib/
RUN cd /usr/local/ && ln -s hadoop-2.6.0-cdh5.4.2-sfdc-1.1.0 hadoop
COPY config/ /usr/local/hadoop/etc/hadoop/
RUN chmod +x /usr/local/hadoop/etc/hadoop/*env.sh
RUN $HADOOP_PREFIX/bin/hdfs namenode -format
CMD ["bash"]
