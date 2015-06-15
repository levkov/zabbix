#/bin/sh

ssh-keygen -f "/root/.ssh/known_hosts" -R [localhost]:220
docker run -p 220:22 -p 80:80 -p 9001:9001 -p 10051:10051 -d levkov/zabbix

