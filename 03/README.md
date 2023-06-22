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

pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE /dev/vg_root
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
ls /mnt

for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done
```

В файле /boot/grub2/grub.cfg заменить rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=vg_root/lv_root
```
vi /boot/grub2/grub.cfg
```
Немного работы с vi
- ```/``` - поиск по тексту
- ```i``` - режим редактирования
- ```ctrl+:``` - ввод команд:
- ```q``` - выход без сохранения
- ```wq``` - сохранить и выйти

```
reboot
```
