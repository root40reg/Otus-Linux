echo "
# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
" >> /etc/sysconfig/watchlog

touch /var/log/watchlog.log

echo "
#!/bin/bash
WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi
" >> /opt/watchlog.sh

chmod +x /opt/watchlog.sh

echo "
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
" >> /etc/systemd/system/watchlog.service

echo "
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/watchlog.timer

systemctl start watchlog.timer

#################

yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y

sed '7,8s/^#//' -i /etc/sysconfig/spawn-fcgi

echo "
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/spawn-fcgi.service

systemctl start spawn-fcgi
#systemctl status spawn-fcgi

##############

echo "
[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C
EnvironmentFile=/etc/sysconfig/httpd-%I  #добавляем строку
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
" >> /usr/lib/systemd/system/httpd.service

echo "
OPTIONS=-f conf/first.conf
" >> /etc/sysconfig/httpd-first

echo "
OPTIONS=-f conf/second.conf
" >> /etc/sysconfig/httpd-second

cd /etc/httpd/conf
cp httpd.conf first.conf
cp httpd.conf second.conf


sed -i ' 43a \PidFile /var/run/httpd-second.pid' second.conf
sed -i 's/Listen 80/Listen 8080/' second.conf

systemctl start httpd@first
systemctl start httpd@second

ss -tnulp | grep httpd
