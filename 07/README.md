# 07. Управление пакетами. Дистрибьюция софта 
## Описание домашнего задания 
 
- Создать свой RPM пакет (можно взять свое приложение, либо собрать, например, апач с определенными опциями)
- Создать свой репозиторий и разместить там ранее собранный RPM

Реализовать это все либо в Vagrant, либо развернуть у себя через NGINX и дать ссылку на репозиторий.

## Инструкция по выполнению

создадим заранее script.sh в который запишем установку locale и необходимых приложений и добавим запуск скрипта в Vagrantfile
```
vagrant up
vagrant ssh
sudo su
```
загрузим SRPM пакет NGINX
```
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm

rpmdev-setuptree
rpm -i nginx-1.*
```
скачаем и разархивируем последний исходник для openssl - он
потребуется при сборке
```
wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
unzip OpenSSL_1_1_1-stable.zip
```
заранее поставим все зависимости, чтобы в процессе сборки не было ошибок
```
yum-builddep /root/rpmbuild/SPECS/nginx.spec
```
поправим spec файл, чтобы NGINX собирался с необходимыми нам опциями
```
nano rpmbuild/SPECS/nginx.spec
```
В build добавляем (примерно 114 строка) ```--with-openssl=/home/vagrant/openssl-OpenSSL_1_1_1-stable \ ```

собираем RPM пакет
```
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
```
Убедимся, что пакеты создались
```
ll /root/rpmbuild/RPMS/x86_64/
```
Теперь можно установить наш пакет и убедиться, что nginx работает
```
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm

systemctl start nginx
systemctl status nginx
```
создадём каталог repo в  директории NGINX и копируем собранный пакет
```
mkdir /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm  /usr/share/nginx/html/repo/
```
загружаем Percona-Server
```
wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
```
инициализируем репозиторий командой:
``` createrepo /usr/share/nginx/html/repo/ ```

настроим в NGINX доступ к листингу каталога:
в ```location / ``` в файле ```/etc/nginx/conf.d/default.conf ``` добавим директиву ```autoindex on;``` 
```
nano /etc/nginx/conf.d/default.conf
```
В результате location будет выглядеть так:
```
location / {
root /usr/share/nginx/html;
index index.html index.htm;
autoindex on; < Добавили эту директиву
```
проверяем синтаксис и перезапускаем NGINX
```
nginx -t
nginx -s reload
```

проверяем работу сайта
```curl -a http://localhost/repo/ ```

добавим настроенынй репозиторий в ```/etc/yum.repos.d```
```
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
```

Убедимся, что репозиторий подключился и посмотрим, что в нем есть
```
yum repolist enabled | grep otus
yum list | grep otus
```
установим из нашего репозитория пакет
```
yum install percona-orchestrator.x86_64 -y
```
# Примечания:
В случае, если потребуется обновить репозиторий (а это
делается при каждом добавлении файлов) снова, то необходимо выполнить команду
```createrepo /usr/share/nginx/html/repo/```

