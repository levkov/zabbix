FROM ubuntu:14.04
MAINTAINER levkov
RUN locale-gen en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install wget -y
RUN wget http://repo.zabbix.com/zabbix/2.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_2.4-1+trusty_all.deb && dpkg -i zabbix-release_2.4-1+trusty_all.deb
RUN apt-get upgrade -y && apt-get install wget vim mc iptraf nmon htop apache2 openssh-server supervisor mlocate zabbix-agent zabbix-server-mysql zabbix-frontend-php php5-mysql -y

COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY conf/zabbix.conf /etc/apache2/conf-available/zabbix.conf
COPY bin/dfg.sh /usr/local/bin/dfg.sh
RUN chmod +x /usr/local/bin/dfg.sh
RUN a2enconf zabbix.conf 
 
RUN chmod -R 0777  /etc/zabbix && mkdir /var/run/zabbix && chmod -R 0777 /var/run/zabbix
RUN gunzip /usr/share/zabbix-server-mysql/*.gz
RUN /bin/bash -c "/usr/bin/mysqld_safe &" && \
  sleep 5 && \
  mysql -e "create user 'zabbix'@'localhost';" && \
  mysql -e "create database zabbix;" && \
  mysql -e "grant all privileges on zabbix.* to 'zabbix'@'localhost';" && \
  mysql -e "flush privileges;" && \
  mysql zabbix < /usr/share/zabbix-server-mysql/schema.sql && \
  mysql zabbix < /usr/share/zabbix-server-mysql/images.sql && \
  mysql zabbix < /usr/share/zabbix-server-mysql/data.sql

#----------------------------------------------------------------------------------------------------
RUN mkdir -p /var/run/sshd /var/log/supervisor
#------------------------------------------------------------------------------------------------------
RUN echo 'root:zabbix?!' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
#-------------------------------------------------------------------------------------------------------

RUN updatedb

EXPOSE 22 80 10051
CMD ["/usr/bin/supervisord"]

