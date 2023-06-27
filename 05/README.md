04



zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi

zpool status
zpool list

Добавим разные алгоритмы сжатия в каждую файловую систему:
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4

Проверим
zfs get all | grep compression

Скачаем один и тот же текстовый файл во все пулы:
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done

Проверим, сколько места занимает один и тот же файл в разных пулах и
проверим степень сжатия файлов:
[root@zfs ~]# zfs list
NAME USED AVAIL REFER MOUNTPOINT
otus1 21.6M 330M 21.5M /otus1
otus2 17.7M 334M 17.6M /otus2
otus3 10.8M 341M 10.7M /otus3
otus4 39.0M 313M 38.9M /otus4
[root@zfs ~]# zfs get all | grep compressratio | grep -v ref

Таким образом, у нас получается, что алгоритм gzip-9 самый эффективный
по сжатию.

2. Определение настроек пула
Скачиваем архив из методички
wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'

Разархивируем
tar -xzvf archive.tar.gz

Проверим, возможно ли импортировать данный каталог в пул:
zpool import -d zpoolexport/

Сделаем импорт данного пула к нам в ОС:
zpool import -d zpoolexport/ otus
zpool status

Далее нам нужно определить настройки
zpool get all otus
Размер: zfs get available otus
[root@zfs ~]# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -

Тип: zfs get readonly otus
[root@zfs ~]# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default
По типу FS мы можем понять, что позволяет выполнять чтение и запись
Значение recordsize: zfs get recordsize otus
[root@zfs ~]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local

Тип сжатия (или параметр отключения): zfs get compression otus
[root@zfs ~]# zfs get compression otus
NAME  PROPERTY     VALUE     SOURCE
otus  compression  zle       local

Тип контрольной суммы: zfs get checksum otus
[root@zfs ~]# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local

3. Работа со снапшотом, поиск сообщения от преподавателя
Скачаем файл, указанный в задании:
wget -O otus_task2.file --no-check-certificate "https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download"
zfs receive otus/test@today < otus_task2.file
Далее, ищем в каталоге /otus/test файл с именем “secret_message”:
[root@zfs ~]# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
[root@zfs ~]#

Смотрим содержимое найденного файла:
[root@zfs ~]# cat /otus/test/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
[root@zfs ~]#
cvj
Тут мы видим ссылку на GitHub, можем скопировать её в адресную строку и посмотреть репозиторий.
