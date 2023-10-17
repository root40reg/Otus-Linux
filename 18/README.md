# 18. Docker

## Описание задания
- Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен 
отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx).
- Определите разницу между контейнером и образом. Вывод опишите в домашнем задании.
- Ответьте на вопрос: Можно ли в контейнере собрать ядро?

## Инструкция по выполнению

### Создаём образ из файла конфигурациина на базе Alpine
```
docker build -t root40reg/mynginx -f Dockerfile .
# Запускаем контейнер
docker run -dt root40reg/mynginx
# Смотрим id контейнера
docker ps
# Заходим в контейнер указывая его id
docker exec -it (id) bin/sh
```
Заходим в браузере по адресу ```http://172.17.0.2``` и проверяем доступность сайта

### Залить свой образ в свой репозиторий на hub.docker.com
```
docker login
docker push root40reg/mynginx
```

### Загрузить образ с сайта docker
```
docker pull root40reg/mynginx:latest
# Создаем контейнер из образа
docker run -dt root40reg/mynginx
# Сморим в списке id контейнера
docker ps
# Заходим в контейнер
docker exec -it 8ce95c0be06f bin/sh
```

### Удалить контейнер
```
docker ps
docker rm (id) -f
```
### Удалить образ
```
docker images
docker rmi (id) -f
```



