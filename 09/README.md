vagrant up
vagrant ssh
sudo su
#######timedatectl set-timezone Europe/Moscow

создаём файл с конфигурацией для сервиса в директории /etc/sysconfig 
vi /etc/sysconfig/watchlog
содержимое файла:
--------------
# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
-------------

Создаем log файл
touch /var/log/watchlog.log

Создадим скрипт:
vi /opt/watchlog.sh

содержимое файла:
----------
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
-----------

Добавим права на запуск файла:
chmod +x /opt/watchlog.sh

vi /etc/systemd/system/watchlog.service
содержимое файла:
-----------
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
------------

vi /etc/systemd/system/watchlog.timer
содержимое файла:
------------
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
-------------
Запускаем timer:
systemctl start watchlog.timer

tail -f /var/log/messages

--------------------------------
--------------------------------

yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
/etc/rc.d/init.d/spawn-fcgi - cам Init скрипт, который будем переписывать

Но перед этим необходимо раскомментировать строки с переменными в /etc/sysconfig/spawn-fcgi
vi /etc/sysconfig/spawn-fcgi
vi /etc/systemd/system/spawn-fcgi.service
--------
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
---------

systemctl start spawn-fcgi
systemctl status spawn-fcgi
-----------------------------
-----------------------------
Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами
Для запуска нескольких экземпляров сервиса будем использовать шаблон в
конфигурации файла окружения (/usr/lib/systemd/system/httpd.service ):
vi /usr/lib/systemd/system/httpd.service
--------
[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service

After=network.target remote-fs.target nss-lookup.target httpd-
init.service
------
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C
EnvironmentFile=/etc/sysconfig/httpd-%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
-------

vi /etc/sysconfig/httpd-first
-----
OPTIONS=-f conf/first.conf
-----
vi /etc/sysconfig/httpd-second
-----
OPTIONS=-f conf/second.conf
-----
cd /etc/httpd/conf
cp httpd.conf first.conf
cp httpd.conf second.conf
vi second.conf
 правим параметры на
PidFile /var/run/httpd-second.pid
Listen 8080

Запускаем и проверяем работу
systemctl start httpd@first
systemctl start httpd@second
Проверить можно несколькими способами, например, посмотреть, какие порты слушаются:

ss -tnulp | grep httpd
