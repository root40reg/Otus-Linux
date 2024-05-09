43.


node1
vagrant ssh node1
sudo -u postgres psql
sudo -u postgres psql
CREATE DATABASE otus_test;
\l
select * from pg_stat_replication;

node2
vagrant ssh node2
sudo -u postgres psql
\list
select * from pg_stat_wal_receiver;

sudo -i
su barman
barman switch-wal node1
barman cron
barman check node1
запускаем бэкап
barman backup node1


node1:
sudo -i
su postgres
psql
\l
DROP DATABASE otus;
\l

systemctl restart postgresql-14.service

barman:
barman list-backup node1
barman recover node1 20240509T132707 /var/lib/pgsql/14/data/ --remote-ssh-comman "ssh postgres@192.168.57.11"

node1:
sudo -i
systemctl restart postgresql-14.service
su postgres
psql
\l

