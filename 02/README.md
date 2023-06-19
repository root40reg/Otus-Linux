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
cat /proc/mdstat
```


