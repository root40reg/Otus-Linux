# 06. NFS, FUSE
## Описание домашнего задания 
 
- ```vagrant up``` должен поднимать 2 настроенных виртуальных машины (сервер NFS и клиента) без дополнительных ручных действий; - на сервере NFS должна быть подготовлена и экспортирована директория; 
- в экспортированной директории должна быть поддиректория с именем __upload__ с правами на запись в неё; 
- экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab -  любым способом); 
- монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3 по протоколу UDP; 
- firewall должен быть включен и настроен как на клиенте, так и на сервере. 

## Инструкция по выполнению

запускаем VPN

```vagrant up```

### Заходим на сервер NFS
```
vagrant ssh nfss
sudo su
```
устанавлием утилиты, которые облегчат отладку
```
yum install nfs-utils
```
запускаем Firewall
```
systemctl enable firewalld --now
systemctl status firewalld
```
разрешаем в firewall доступ к сервисам NFS
```
firewall-cmd --add-service="nfs3" \
--add-service="rpc-bind" \
--add-service="mountd" \
--permanent
firewall-cmd --reload
```
включаем сервер NFS
```
systemctl enable nfs --now
```
проверяем порты в 2049/udp, 2049/tcp, 20048/udp, 20048/tcp, 111/udp, 111/tcp
```
ss -tnplu
```
создаём и настраиваем директорию, которая будет экспортирована в будущем
```
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload
```
создаём в файле ```/etc/exports``` структуру, которая позволит экспортировать ранее созданную директорию
```
cat << EOF > /etc/exports
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF
```
экспортируем директорию
```exportfs -r```
проверяем экспортированную директорию
```exportfs -s```

### Заходим на клиента NFS
```
vagrant ssh nfsc
sudo su
```
делаем действия аналогичные серверу
```
yum install nfs-utils
systemctl enable firewalld --now
systemctl status firewalld
```
добавляем в ```/etc/fstab``` строку
```echo "192.168.50.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
```
в данном случае происходит автоматическая генерация ```systemd units``` в каталоге ```/run/systemd/generator/```, которые производят монтирование при первом обращении к каталогу ```/mnt/```

```mount | grep mnt```
вывод должен быть таким:
```
systemd-1 on /mnt type autofs (rw,relatime,fd=23,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=28532)
```
### Проверка работоспособности 
- заходим на сервер 
- заходим в каталог ```/srv/share/upload```
- создаём тестовый файл ```touch check_file```
- заходим на клиент 
- заходим в каталог ```/mnt/upload```
- проверяем наличие ранее созданного файла 
- создаём тестовый файл ```touch client_file```
- проверяем, что файл успешно создан

### Примечания
- проверяем работу RPC на клиенте		```showmount -a 192.168.50.10```
- проверяем статус монтирования на клиенте	```mount | grep mnt```
