# 02. Дисковая система

## Создание RAID6

Берём [Vagrantfile из методички](https://github.com/erlong15/otus-linux), меняем параметры:

Убираем строку
```
 :ip_addr => '192.168.11.101'
```
Добавляем
```
,
     :sata5 => {
                :dfile => './sata5.vdi', # Путь, по которому будет создан файл диска
                :size => 250, # Размер диска в мегабайтах
                :port => 5 # Номер порта, на который будет зацеплен диск
               }
```
В раздел ```box.vm.provision``` добавляем

```
cp /vagrant/raid6.sh /home/vagrant
```
Кладём созданный скрипт ```raid6.sh``` в директорию с Vagrantfile

Далее выполняем команды
```
vagrant up
vagrant ssh
sudo sh raid6.sh
[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid6 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 level 6, 512k chunk, algorithm 2 [5/5] [UUUUU]
      
unused devices: <none>
```

#Сломать/починить RAID

Разрушаем один диск
```
sudo su
mdadm /dev/md0 --fail /dev/sde
```
Проверяем
```
cat /proc/mdstat
mdadm -D /dev/md0
```
Удаляем диск из массива
```
mdadm /dev/md0 --remove /dev/sde
```
вставляем новый 
```
mdadm /dev/md0 --add /dev/sde
```
проверяем статус
```
cat /proc/mdstat
mdadm -D /dev/md0
```
Мы успешно разрушили и восстановили RAID-массив
