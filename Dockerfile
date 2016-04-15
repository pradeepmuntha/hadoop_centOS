FROM pradeepmuntha/hadoop_centos_autobuild:v1 
RUN yum -y install httpd; yum clean all
EXPOSE 80
RUN sleep5; service httpd start
