# 22. Пользователи и группы. Авторизация и аутентификация 
## Описание домашнего задания
- Запретить всем пользователям, кроме группы admin, логин в выходные (суббота и воскресенье), без учета праздников
- * дать конкретному пользователю права работать с докером и возможность рестартить докер сервис

## Инструкция по выполнению

Меняеем в Vagrantfile ```:box_name => "generic/centos8s",``` добавляем ```yum install nano -y```

Запускаем ВМ
```
vagrant up
vagrant ssh
sudo -i
```
Создаём пользователя otusadm и otus
```
useradd otusadm && sudo useradd otus
```
Создаём пользователям пароли
```
echo "Otus2023!" | sudo passwd --stdin otusadm && echo "Otus2023!" | sudo passwd --stdin otus
```
Создаём группу admin
```
groupadd -f admin
```
Добавляем пользователей vagrant,root и otusadm в группу admin
```
  usermod otusadm -a -G admin && usermod root -a -G admin && usermod vagrant -a -G admin
```
Пробуем подключиться с новой сессии к ВМ под новыми пользователями
```
ssh otus@192.168.57.10
exit
```
Проверим, что пользователи root, vagrant и otusadm есть в группе admin
```
cat /etc/group | grep admin
```
Создадим файл-скрипт ```/usr/local/bin/login.sh```
```
nano /usr/local/bin/login.sh
```
Содержимое:
```
#!/bin/bash
#Первое условие: если день недели суббота или воскресенье
if [ $(date +%a) = "Sat" ] || [ $(date +%a) = "Sun" ]; then
 #Второе условие: входит ли пользователь в группу admin
 if getent group admin | grep -qw "$PAM_USER"; then
        #Если пользователь входит в группу admin, то он может подключиться
        exit 0
      else
        #Иначе ошибка (не сможет подключиться)
        exit 1
    fi
  #Если день не выходной, то подключиться может любой пользователь
  else
    exit 0
fi
```

Добавим права на исполнение файла
```
chmod +x /usr/local/bin/login.sh
```
Добавим в конец файла ```/etc/pam.d/sshd``` строку ```auth required pam_exec.so /usr/local/bin/login.sh```
```
nano /etc/pam.d/sshd
```

date 082712302022.00
