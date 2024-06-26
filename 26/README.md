# 26. Резервное копирование 
## Описание домашнего задания:
Методичка
https://docs.google.com/document/d/1L0VtVCn2tXmC0Pirlfhnr6rEpOANbP-C/edit?usp=share_link&ouid=104106368295333385634&rtpof=true&sd=true

Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.

Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:
- директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB;
- репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение;
- имя бекапа должно содержать информацию о времени снятия бекапа;
- глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;
- резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;
- написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение;
- настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов.

  Запустите стенд на 30 минут.
  
  Убедитесь что резервные копии снимаются.
  
  Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа.
  
  Для сдачи домашнего задания ожидаем настроенные стенд, логи процесса бэкапа и описание процесса восстановления.
  
  Формат сдачи ДЗ - vagrant + ansible

## Инструкция по выполнению

```
vagrant up
vagrant ssh client
```
Проверка работы таймера 
```
systemctl list-timers --all
```
Просмотр логов
```
cat /var/log/messages | grep borg
```
Просмотр списка бэкапов
```
sudo su - borg
borg list borg@192.168.56.10:/var/backup/
```
Просмотр списка файлов в бэкапе и извлечение всей директории из архива
```
borg list borg@192.168.56.10:/var/backup/::etc-2021-10-15_23:00:15
borg extract borg@192.168.56.10:/var/backup/::etc-2021-10-15_23:00:15 etc/
```
