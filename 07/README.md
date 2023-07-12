sudo yum install -y \
redhat-lsb-core \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils \
gcc


Загрузим SRPM пакет NGINX для дальнейшей работы над ним:
[root@packages ~]#
wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm
rpmdev-setuptree
rpm -i nginx-1.*
wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
unzip OpenSSL_1_1_1-stable.zip

yum-builddep /root/rpmbuild/SPECS/nginx.spec
поправить сам spec файл, чтобы NGINX собирался с необходимыми нам опциями:
vi rpmbuild/SPECS/nginx.spec
В build добавляем(примерно 114 строка):
--with-openssl=/home/vagrant/openssl-OpenSSL_1_1_1-stable \

собираем RPM пакет
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
Убедимся, что пакеты создались
ll /root/rpmbuild/RPMS/x86_64/

Теперь можно установить наш пакет и убедиться, что nginx работает
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm

systemctl start nginx
systemctl status nginx


mkdir /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm  /usr/share/nginx/html/repo/

wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
Инициализируем репозиторий командой:
createrepo /usr/share/nginx/html/repo/


Для прозрачности настроим в NGINX доступ к листингу каталога:
● В location / в файле /etc/nginx/conf.d/default.conf добавим директиву autoindex on. 
nano /etc/nginx/conf.d/default.conf
В результате location будет выглядеть так:
location / {
root /usr/share/nginx/html;
index index.html index.htm;
autoindex on; < Добавили эту директиву

Проверяем синтаксис и перезапускаем NGINX:
nginx -t
nginx -s reload


проверяем работу сайта
curl -a http://localhost/repo/

cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

Убедимся, что репозиторий подключился и посмотрим, что в нем есть
yum repolist enabled | grep otus
yum list | grep otus

yum install percona-orchestrator.x86_64 -y


 В случае, если вам потребуется обновить репозиторий (а это
делается при каждом добавлении файлов) снова, то выполните команду
createrepo /usr/share/nginx/html/repo/

