FROM ubuntu:14.04
MAINTAINER levkov
ENV DEBIAN_FRONTEND noninteractive
COPY bin/dfg.sh /usr/local/bin/dfg.sh

RUN locale-gen en_US.UTF-8 && \
    apt-get update && apt-get install wget -y && \
    wget http://repo.zabbix.com/zabbix/3.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.0-1+trusty_all.deb && \ 
    dpkg -i zabbix-release_3.0-1+trusty_all.deb && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install postfix vim apache2 openssh-server supervisor zabbix-agent zabbix-server-mysql zabbix-frontend-php zabbix-java-gateway php5-mysql -y && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \ 

    chmod +x /usr/local/bin/dfg.sh && \
    a2enconf zabbix.conf && \
    chmod -R 0777  /etc/zabbix && \
    mkdir /var/run/zabbix && \
    chmod -R 0777 /var/run/zabbix && \
    /bin/bash -c "/usr/bin/mysqld_safe &" && \
    sleep 5 && \
    mysql -e "create user 'zabbix'@'localhost';" && \
    mysql -e "create database zabbix;" && \
    mysql -e "grant all privileges on zabbix.* to 'zabbix'@'localhost';" && \
    mysql -e "flush privileges;" && \
    cd /usr/share/doc/zabbix-server-mysql && zcat create.sql.gz | mysql -uroot zabbix

#----------------------------------------------------------------------------------------------------
    mkdir -p /var/run/sshd /var/log/supervisor && \
#------------------------------------------------------------------------------------------------------
    echo 'root:zabbix?!' | chpasswd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile

#-------------------------------------------S3 Tools----------------------------------------------    
RUN wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add - && \
    wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list && \
    apt-get update && apt-get -y install s3cmd && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
#-------------------------------------------------------------------------------------------------    
    
ENV NOTVISIBLE "in users profile"
#-------------------------------------------------------------------------------------------------------

COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY conf/zabbix.conf /etc/apache2/conf-available/zabbix.conf
# COPY conf/zabbix_server.conf /etc/zabbix/zabbix_server.conf

VOLUME /var/lib/mysql

EXPOSE 10051 22 80 
CMD ["/usr/bin/supervisord"]

