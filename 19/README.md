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
