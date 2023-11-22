28.

# 28. DHCP, PXE
## Описание домашнего задания:
Настраиваем центральный сервер для сбора логов.

Для выполнения домашнего задания используйте методичку
https://docs.google.com/document/d/1f5I8vbWAk8ah9IFpAQWN3dcWDHMqXzGb/edit?usp=share_link&ouid=104106368295333385634&rtpof=true&sd=true

- Следуя шагам из документа https://docs.centos.org/en-US/8-docs/advanced-install/assembly_preparing-for-a-network-install установить и настроить загрузку по сети для дистрибутива CentOS8.
- В качестве шаблона воспользуйтесь репозиторием https://github.com/nixuser/virtlab/tree/main/centos_pxe.
- Поменять установку из репозитория NFS на установку из репозитория HTTP.
- Настроить автоматическую установку для созданного kickstart файла (*) Файл загружается по HTTP.

## Инструкция по выполнению

Заранее скачиваем ISO-образ для автоматической установки на клиентской машине

```
wget https://mirror.cs.pitt.edu/centos-vault/8.4.2105/isos/x86_64/CentOS-8.4.2105-x86_64-dvd1.iso
```
Запускаем ВМ (при необходимости изменить путь до ISO в Vagrantfile)

```
vagrant up
```

Не обращаем внимание на ошибку соединения с клиентом ```pxeclient: Warning: Connection refused. Retrying...```

Переходим в Virtualbox и наблюдаем процесс установки ОС CentOS-8.4.

![image](https://github.com/root40reg/Otus-Linux/assets/132127335/6539ba05-7d1e-4b5f-878d-71b5041e33a3)

При желании можно просто перезагрузить ВМ и выбрать другой способ установки

![image](https://github.com/root40reg/Otus-Linux/assets/132127335/9418a383-73d0-4d77-a77c-d61eb9bfee32)




