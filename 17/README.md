# 17. SELinux - когда все запрещено
## Описание задания
Для выполнения домашнего задания используйте методичку
https://docs.google.com/document/d/1QwyccIn8jijBKdaoNR4DCtTULEqb5MKK/edit?usp=share_link&ouid=104106368295333385634&rtpof=true&sd=true

### 1. Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.

### 2. Обеспечить работоспособность приложения при включенном selinux.
- развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
- выяснить причину неработоспособности механизма обновления зоны (см. README);
- предложить решение (или решения) для данной проблемы;
- выбрать одно из решений для реализации, предварительно обосновав выбор;
- реализовать выбранное решение и продемонстрировать его работоспособность.

## Инструкция по выполнению
```
sudo -i
```
Проверяем, что файервол выключен:
```
systemctl status firewalld
```
Проверяем конфигурация nginx: 
```
nginx -t
```
Смотрим режим работы SELinux: 
```
getenforce
```

## 3 способа разрешить в SELinux работу nginx на порту TCP 4881 
### 1. С помощью переключателей setsebool
устанавливаем ```audit2why``` командой ```yum install -y policycoreutils-python```

Находим в ```/var/log/audit/audit.log``` информацию о блокировании порта

Копируем время, в которое был записан этот лог, и с помощью утилиты audit2why смотрим
```
grep 1696849181.168:1062 /var/log/audit/audit.log | audit2why
```
Утилита ```audit2why``` покажет, почему трафик блокируется. Исходя из вывода утилиты, мы видим, что нам нужно поменять параметр ```nis_enabled```. 
Включим параметр ```nis_enabled``` и перезапустим nginx: 
```
setsebool -P nis_enabled on
systemctl restart nginx
systemctl status nginx
```
Проверяем работу nginx из браузера. Заходим в браузер на хосте и переходим по адресу ```http://127.0.0.1:4881```
Проверить статус параметра можно с помощью команды:
```
getsebool -a | grep nis_enabled
```
Вернём запрет работы nginx на порту 4881:
```
setsebool -P nis_enabled off
```
### 2. С помощью добавления нестандартного порта в имеющийся тип
Поиск имеющегося типа, для http трафика: 
```
semanage port -l | grep http
```
Добавим порт в тип http_port_t: 
```
semanage port -a -t http_port_t -p tcp 4881
```
Проверяем
```
semanage port -l | grep  http_port_t
systemctl restart nginx
systemctl status nginx
```
Удаляем нестандартный порт из имеющегося типа:
```
semanage port -d -t http_port_t -p tcp 4881
```

### 3. С помощью формирования и установки модуля SELinux:
Воспользуемся утилитой ```audit2allow``` для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту: 
```
grep nginx /var/log/audit/audit.log | audit2allow -M nginx
```
Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль:
```
semodule -i nginx.pp
```
Проверяем работу nginx
```
systemctl start nginx
systemctl status nginx
```
При использовании модуля изменения сохранятся после перезагрузки.

Просмотр всех установленных модулей:
```
semodule -l
```
Удалим модуль: 
```
semodule -r nginx
```
----------
Вторая часть задания делается по методичке, проблем не возникло
