28.

# 28. DHCP, PXE
## Описание домашнего задания:
Настраиваем центральный сервер для сбора логов.

Для выполнения домашнего задания используйте методичку
https://docs.google.com/document/d/1f5I8vbWAk8ah9IFpAQWN3dcWDHMqXzGb/edit?usp=share_link&ouid=104106368295333385634&rtpof=true&sd=true

Следуя шагам из документа https://docs.centos.org/en-US/8-docs/advanced-install/assembly_preparing-for-a-network-install установить и настроить загрузку по сети для дистрибутива CentOS8.

В качестве шаблона воспользуйтесь репозиторием https://github.com/nixuser/virtlab/tree/main/centos_pxe.

Поменять установку из репозитория NFS на установку из репозитория HTTP.

Настроить автоматическую установку для созданного kickstart файла (*) Файл загружается по HTTP.

## Инструкция по выполнению

Заранее скачиваем ISO-образ для автоматической установки на клиентской машине

```
wget https://mirror.cs.pitt.edu/centos-vault/8.4.2105/isos/x86_64/CentOS-8.4.2105-x86_64-dvd1.iso
```
Запускаем ВМ (при необходимости изменить путь до ISO в Vagrantfile)

```
vagrant up
```

Не обращаем внимае на ошибку соединения с клиентом

Переходим в Virtualbox и наблюдаем процесс установки ОС CentOS-8.4. При желании можно просто перезагрущить ВМ и выбрать другой способ установки

