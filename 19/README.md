# 21. Prometheus
## Описание задания
Настроить дашборд с 4-мя графиками
- память;
- процессор;
- диск;
- сеть.

В качестве результата прислать скриншот экрана - дашборд должен содержать в названии имя приславшего.

## Инструкция по выполнению

Перед запуском vagrantfile скачать и положить в каталог ```files``` rpm пакет Grafana
```https://cloud.mail.ru/public/Zo61/yJgGrrfcr```
```
vagrant up
vagrant ssh
sudo -i
yum -y install /root/grafana-enterprise-9.5.2-1.x86_64.rpm
# Стартуем сервис
systemctl daemon-reload
systemctl start grafana-server
```
Проверка Prometheus

http://192.168.56.10:9090/graph

Проверка NodeExporter

http://192.168.56.10/targets

http://192.168.56.10:9100/metrics

Проверка Grafana

http://192.168.56.10:3000 (admin/admin)

Во время настройки Grafana не забываем указывать порт 9090
![02](https://github.com/root40reg/Otus-Linux/assets/132127335/5c2768b2-86ea-4f45-a75e-06bd48a6919a)

Также указываем актуальную версию Prometheus

![03](https://github.com/root40reg/Otus-Linux/assets/132127335/071aea4e-ba3f-4ff2-91a9-ce4fdf63ddea)

При корректной настройке вместо No Data отобразятся необходимые графики
![01](https://github.com/root40reg/Otus-Linux/assets/132127335/16a33c5c-4764-49db-b93d-969a179e5f86)




