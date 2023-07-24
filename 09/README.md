# 09. Инициализация системы. Systemd.
## Описание задания
- Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
- Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
- Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.

## Инструкция по выполнению

### 1. service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова

```
vagrant up
vagrant ssh
sudo su
```

создаём файл с конфигурацией для сервиса в директории ```/etc/sysconfig```

```vi /etc/sysconfig/watchlog```

содержимое файла:

```
# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
```

Создаем log файл

```touch /var/log/watchlog.log```

Создадим скрипт:

```vi /opt/watchlog.sh```

содержимое файла:
```
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
```

Добавим права на запуск файла:

```chmod +x /opt/watchlog.sh```

Создадим юнит для сервиса

```vi /etc/systemd/system/watchlog.service```

содержимое файла:
```
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
```

Создадим юнит для таймера:

```vi /etc/systemd/system/watchlog.timer```

содержимое файла:

```
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
```

Запускаем и проверяем timer:
```
systemctl start watchlog.timer
tail -f /var/log/messages
```

### 2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл

```yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y```

```/etc/rc.d/init.d/spawn-fcgi``` - Init скрипт, который будем переписывать

Раскомментируем строки с переменными в ```/etc/sysconfig/spawn-fcgi```
```
vi /etc/sysconfig/spawn-fcgi
```

Создадим юнит

```vi /etc/systemd/system/spawn-fcgi.service```

содержимое файла:
```
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
```

Запускаем и проверяем

```
systemctl start spawn-fcgi
systemctl status spawn-fcgi
```

### 3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера

Для запуска нескольких экземпляров сервиса будем использовать шаблон в
конфигурации файла окружения:
```
vi /usr/lib/systemd/system/httpd.service
```

содержимое файла:

```
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
```

```vi /etc/sysconfig/httpd-first```

содержимое файла:

```OPTIONS=-f conf/first.conf```

```vi /etc/sysconfig/httpd-second```

содержимое файла:

```OPTIONS=-f conf/second.conf```

```
cd /etc/httpd/conf
cp httpd.conf first.conf
cp httpd.conf second.conf
vi second.conf
```
правим параметры на

```
PidFile /var/run/httpd-second.pid
Listen 8080
```
Запускаем и проверяем работу

```
systemctl start httpd@first
systemctl start httpd@second

ss -tnulp | grep httpd
```
