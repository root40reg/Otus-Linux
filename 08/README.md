# 08. Загрузка системы
## Описание задания
- Попасть в систему без пароля несколькими способами
- Установить систему с LVM, после чего переименовать VG
- Добавить модуль в initrd

## Инструкция по выполнению

### Вход без пароля
#### Способ 1. ```init=/bin/sh```

● в конце строки, начинающейся с linux16, добавляем ```init=/bin/sh``` и нажимаем ```сtrl-x``` для загрузки в систему
● перемонтируем в режим Read-Write и создадим файл:
```mount -o remount,rw /```
проверяем
```
mount | grep root
touch test01
```

#### Способ 2. ```rd.break```

В конце строки, начинающейся с linux16, добавляем ```rd.break``` и нажимаем сtrl-x для загрузки в систему
Перемонтируем в режим Read-Write и сменим пароль root:
```
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel
```
Перезагружаемся и заходим в систему с новым паролем.

#### Способ 3. ```rw init=/sysroot/bin/sh```
В строке, начинающейся с linux16, заменяем ro на rw init=/sysroot/bin/sh и нажимаем сtrl-x для загрузки в систему
Система уже смонтирована в режим Read-Write. Создадим каталог
```
mkdir test2
```

### Установить систему с LVM, после чего переименовать VG
Смотрим текущее состояние системы
```
vagrant up 
vagrant ssh
sudo su
```
Смотрим текущее состояние системы
```
[root@centos7 vagrant]# vgs
  VG             #PV #LV #SN Attr   VSize    VFree
  centos_centos7   1   2   0 wz--n- <127,00g    0 
```
Переименовываем LVM
```
[root@centos7 vagrant]# vgrename centos_centos7 OtusRoot
  Volume group "centos_centos7" successfully renamed to "OtusRoot"
```

Правим ```/etc/fstab```, ```/etc/default/grub```, ```/boot/grub2/grub.cfg```. Везде меняем старое
название на новое.

Пересоздаем initrd image, чтобы он знал новое название Volume Group
```
[root@centos7 vagrant]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-1160.88.1.el7.x86_64.img' done ***
```
Перезагружаемся и проверяем
```
[root@centos7 vagrant]# vgs
  VG       #PV #LV #SN Attr   VSize    VFree
  OtusRoot   1   2   0 wz--n- <127,00g    0 
```

### Добавить модуль в initrd
Создадим свой каталог в каталоге модулей
```
mkdir /usr/lib/dracut/modules.d/01test
```
Разместим два скрипта
```
module-setup.sh  # устанавливает модуль и вызывает скрипт test.sh
test.sh          # сам скрипт с пингвинчиком
```
Пересобираем образ initrd
```
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
```
или
```
dracut -f -v
```
Проверим список загруженых модулей
```
lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
```
После чего можно пойти двумя путями для проверки:
- Перезагрузиться и руками выключить опции rghb и quiet и увидеть вывод
- Отредактировать файл ```/boot/grub2/grub.cfg```, убрав эти опции

После перезагрузки в окне virtualbox наблюдаем пингвинчика :)

![Пингвинчик](https://github.com/root40reg/Otus-Linux/blob/main/08/08_01.jpg)







