# 05. ZFS
## Домашнее задание

- Определить алгоритм с наилучшим сжатием
- Определить какие алгоритмы сжатия поддерживает zfs (gzip, zle, lzjb, lz4);
- Создать 4 файловых системы на каждой применить свой алгоритм сжатия;
Для сжатия использовать либо текстовый файл, либо группу файлов:
- Определить настройки пула
- С помощью команды zfs import собрать pool ZFS;
- Командами zfs определить настройки:
    - размер хранилища;
    - тип pool;
    - значение recordsize;
    - какое сжатие используется;
    - какая контрольная сумма используется.
Работа со снапшотами
- Скопировать файл из удаленной директории.   https://drive.google.com/file/d/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG/view?usp=sharing 
- Восстановить файл локально. zfs receive
- Найти зашифрованное сообщение в файле secret_message

## Инструкция по выполнению
## 1. Определение алгоритма с наилучшим сжатием
Смотрим список всех дисков
```
lsblk
```
Создаём 4 пула из дисков в режиме RAID 1
```
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi
```
Проверяем
```
zpool status
zpool list
```
Добавим разные алгоритмы сжатия в каждую файловую систему:
```
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4
```
Проверяем
```
zfs get all | grep compression
```
Скачаем один и тот же текстовый файл во все пулы:
```
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
```
Проверим, сколько места занимает один и тот же файл в разных пулах и проверим степень сжатия файлов:
```
zfs list
zfs get all | grep compressratio | grep -v ref
```
Видим, что алгоритм gzip-9 самый эффективный по сжатию.

## 2. Определение настроек пула
Скачиваем архив из методички
```
wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
```
Разархивируем
```
tar -xzvf archive.tar.gz
```
Проверим, возможно ли импортировать данный каталог в пул
```
zpool import -d zpoolexport/
```
Сделаем импорт данного пула к нам в ОС
```
zpool import -d zpoolexport/ otus
zpool status
```



Далее нам нужно определить настройки
```
zpool get all otus          #Запрос сразу всех параметром файловой системы
zfs get available otus      #Размер
zfs get readonly otus       #Тип
zfs get recordsize otus     #По типу FS мы можем понять, что позволяет выполнять чтение и запись
zfs get compression otus    #Тип сжатия (или параметр отключения)
zfs get checksum otus       #Тип контрольной суммы
```

## 3. Работа со снапшотом, поиск сообщения от преподавателя
Скачаем файл, указанный в задании:
```
wget -O otus_task2.file --no-check-certificate "https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download"
```
Восстановим файловую систему из снапшота
```
zfs receive otus/test@today < otus_task2.file
```
Далее, ищем в каталоге /otus/test файл с именем “secret_message”:
```
find /otus/test -name "secret_message"
```
Смотрим содержимое найденного файла:
```
cat /otus/test/task1/file_mess/secret_message
```
Мы видим ссылку на GitHub, можем скопировать её в адресную строку и посмотреть репозиторий.
