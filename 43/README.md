# 43. Postgres: Backup + Репликация 

## Описание домашнего задания:

Для выполнения домашнего задания используйте [методичку](https://docs.google.com/document/d/1EU_KF3x9e2f75sNL4sghDIxib9eMfqex/edit)

Что нужно сделать?
- настроить hot_standby репликацию с использованием слотов
- настроить правильное резервное копирование

Для сдачи работы присылаем ссылку на репозиторий, в котором должны обязательно быть
Vagranfile (2 машины)
плейбук Ansible
конфигурационные файлы postgresql.conf, pg_hba.conf и recovery.conf,
конфиг barman, либо скрипт резервного копирования.

## Инструкция по выполнению
1. Проверка репликации

node1:
```
vagrant ssh node1
sudo -u postgres psql
CREATE DATABASE otus_test;
\l
select * from pg_stat_replication;
```
node2:
```
vagrant ssh node2
sudo -u postgres psql
\list
select * from pg_stat_wal_receiver;
```

2. Проверка резервного копирования

barman:
```
sudo -i
su barman
barman switch-wal node1
barman cron
barman check node1

# запускаем бэкап
barman backup node1
```

node1:
```
sudo -i
su postgres
psql
\l
DROP DATABASE otus;
\l
```

barman
```
# восстанавливаем базу
barman list-backup node1
barman recover node1 20240509T132707 /var/lib/pgsql/14/data/ --remote-ssh-comman "ssh postgres@192.168.57.11"
```
node1:
```
sudo -i
systemctl restart postgresql-14.service
su postgres
psql
\l
```
