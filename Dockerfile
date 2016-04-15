FROM pradeepmuntha/hadoop_centos_autobuild:v1 
RUN yum -y install httpd; yum clean all; service httpd start 
EXPOSE 80
RUN "/etc/init.d/httpd start"
