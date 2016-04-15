FROM centos:6.7 
RUN yum -y install httpd; yum clean all; service httpd start 
EXPOSE 80
CMD ["/usr/sbin/init"]
CMD ["service httpd start"]
