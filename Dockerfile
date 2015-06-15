FROM ubuntu:14.04
MAINTAINER levkov
RUN locale-gen en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install wget -y
RUN wget http://repo.zabbix.com/zabbix/2.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_2.4-1+trusty_all.deb && dpkg -i zabbix-release_2.4-1+trusty_all.deb
RUN apt-get upgrade -y && apt-get install wget apache2 openssh-server supervisor mlocate zabbix-agent zabbix-server-mysql zabbix-frontend-php php5-mysql -y

RUN updatedb
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN cp /usr/share/doc/zabbix-frontend-php/examples/apache.conf /etc/apache2/conf-available/zabbix.conf
RUN a2enconf zabbix.conf && a2enmod alias

RUN mkdir -p /var/run/sshd /var/log/supervisor
#------------------------------------------------------------------------------------------------------
RUN echo 'root:zabbix?!' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
#-------------------------------------------------------------------------------------------------------
EXPOSE 22 80
CMD ["/usr/bin/supervisord"]
