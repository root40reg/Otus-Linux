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
sudo groupadd -f admin
```
Добавляем пользователей vagrant,root и otusadm в группу admin
```
  usermod otusadm -a -G admin && usermod root -a -G admin && usermod vagrant -a -G admin
```

