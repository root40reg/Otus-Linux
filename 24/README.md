# 24. Основы сбора и хранения логов
## Описание домашнего задания:
Настраиваем центральный сервер для сбора логов.

Для выполнения домашнего задания используйте методичку
https://docs.google.com/document/d/16UBAMu4LYqvRv6PmCeHcmOampMrIZavH/edit?usp=share_link&ouid=104106368295333385634&rtpof=true&sd=true

- В вагранте поднимаем 2 машины web и log
- На web поднимаем nginx
- На log настраиваем центральный лог сервер на любой системе на выбор
- journald;
- rsyslog;
- elk.

Настраиваем аудит, следящий за изменением конфигов нжинкса.

Все критичные логи с web должны собираться и локально и удаленно.

Все логи с nginx должны уходить на удаленный сервер (локально только критичные).

Логи аудита должны также уходить на удаленную систему.

Формат сдачи ДЗ - vagrant + ansible

## Инструкция по выполнению

```
vagrant up
```
Проверяем логи nginx на сервере логов (log):

Попробуем несколько раз зайти по адресу http://192.168.56.10, в том числе и на несуществующюю страницу

Далее заходим на log-сервер и смотрим информацию об nginx:
```
vagrant ssh log
cat /var/log/rsyslog/web/nginx_access.log 
cat /var/log/rsyslog/web/nginx_error.log
```

Проверяем логи аудита на сервере логов (log):

```
ls -l /etc/nginx/nginx.conf
chmod +x /etc/nginx/nginx.conf
ls -l /etc/nginx/nginx.conf
grep web /var/log/audit/audit.log
```





