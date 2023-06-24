# 03. Файловые системы LVM

## Домашнее задание

1. Уменьшить тод под / до 8Gb
2. Выделить том под /home
3. Выделить том под /var - сделать в mirror
4. /home - сделать том для снапшотов
5. Прописать монтирование в fstab. Попробовать с разными опциями и разными файловвыми системами (на выбор)

Работа со снапшотми:
  - сгенерировать файлы в /home/
  - снять снапшот
  - удалить часть файлов
  - восстановить со снапшота

## Инструкция по выполнению
Берём [Vagrantfile из методички](https://gitlab.com/otus_linux/stands-03-lvm), меняем параметры:

Убираем строки
```
 :ip_addr => '192.168.11.101',
box.vm.network "private_network", ip: boxconfig[:ip_addr]
```
Добавляем приложение ```xfsdump``` в конец строки ```yum install -y mdadm smartmontools hdparm gdisk```

Создаём ВМ и начинаем работать
```
vagrant up
vagrant ssh
sudo su

#Подготовим временный том для / раздела
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE /dev/vg_root

#Создадим на нём файловую систему и смонтируем его, чтобы пернести туда данные
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt

#Скопируем все данные с / раздела в /mnt
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
#Проверяем
ls /mnt

#Переконфигурируем grub для того, чтобы при старте перейти в новый /
#Cымитируем текущий root - сделаем в него chroot и обновим grub
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg

#Обновим образ initrd
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
```

В файле /boot/grub2/grub.cfg заменить rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=vg_root/lv_root
```
vi /boot/grub2/grub.cfg
```
Немного работы с vi
- ```/``` - поиск по тексту
- ```i``` - режим редактирования
- ```Shift+:``` - ввод команд:
- ```q``` - выход без сохранения
- ```wq``` - сохранить и выйти

```
#Перезагружаемся
reboot
vagrant ssh
sudo su
```

-----------------------
-----------------------

Проверяем
```
lsblk
```
Удаляем старую LV и создаем новую
```
lvremove /dev/VolGroup00/LogVol00
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
```
Также как в первый раз переконфигурируем grub
```
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;  s/.img//g"` --force; done
```
Не перезагружаемся и не выходим из под chroot - мы можем заодно перенести /var
```
pvcreate /dev/sdc /dev/sdd
vgcreate vg_var /dev/sdc /dev/sdd
lvcreate -L 950M -m1 -n lv_var vg_var
```
Создаем на нем ФС и перемещаем туда /var:
```
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
cp -aR /var/* /mnt/ # rsync -avHPSAX /var/ /mnt/
```
На всякий случай сохраняем содержимое старого var
```
mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
```
Монтируем новый var в каталог var
```
umount /mnt
mount /dev/vg_var/lv_var /var
```
Правим fstab для автоматического монтирования /var
```
echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
```
Перезагружаемся и удаляем временную Volume Groupre
```
lvremove /dev/vg_root/lv_root
vgremove /dev/vg_root
pvremove /dev/sdb
```
Выделяем том под /home
```
lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol_Home
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/
```
Правим fstab для автоматического монтирования /home
```
echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
```
# Работа со снапшотами
Сделаем файлы в /home
```
touch /home/file{1..20}
```
Снять снапшот
```
lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
```
Удалим часть файлов
```
rm -f /home/file{11..20} 
```
Восстановим со снапшота
```
umount /home
lvconvert --merge /dev/VolGroup00/home_snap
mount /home
ls /home
```
