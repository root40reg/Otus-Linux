Задание
1. Попасть в систему без пароля несколькими способами
2. Установить систему с LVM, после чего переименовать VG
3. Добавить модуль в initrd




Инструкция по выполнению
Вход без пароля
Способ 1. init=/bin/sh
● в конце строки, начинающейся с linux16, добавляем init=/bin/sh и нажимаем сtrl-x для загрузки в систему
● перемонтируем в режим Read-Write и создадим файл:
mount -o remount,rw /
проверяем
mount | grep root
touch test01

Способ 2. rd.break

● В конце строки, начинающейся с linux16, добавляем rd.break и нажимаем сtrl-x для загрузки в систему
● перемонтируем в режим Read-Write и сменим пароль root:
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel
● перезагружаемся и заходим в систему с новым паролем.

Способ 3. rw init=/sysroot/bin/sh
● В строке, начинающейся с linux16, заменяем ro на rw init=/sysroot/bin/sh и нажимаем сtrl-x для загрузки в систему
● система уже смонтирована в режим Read-Write. Создадим каталог
mkdir test2

---------------
Установить систему с LVM, после чего переименовать VG
Смотрим текущее состояние системы
[root@centos8s /]# vgs
  VG          #PV #LV #SN Attr   VSize    VFree
  cs_centos8s   1   2   0 wz--n- <127.00g    0

[root@centos8s /]# vgrename cs_centos8s OtusRoot
  Volume group "cs_centos8s" successfully renamed to "OtusRoot"

правим /etc/fstab, /etc/default/grub, /boot/grub2/grub.cfg. Везде заменяем старое
название на новое.
Пересоздаем initrd image, чтобы он знал новое название Volume Group

[root@centos8s /]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
Creating: target|kernel|dracut args|basicmodules 
...
dracut: *** Creating image file '/boot/initramfs-4.18.0-448.el8.x86_64.img' ***
dracut: *** Creating initramfs image file '/boot/initramfs-4.18.0-448.el8.x86_64.img' done ***
