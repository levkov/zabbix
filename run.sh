#/bin/sh


ssh-keygen -f "/root/.ssh/known_hosts" -R [localhost]:223
docker run -p 223:22 -p 8080:80 -p 81:9001 -d levkov/zabbix

