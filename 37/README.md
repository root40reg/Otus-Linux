# 37. Сетевые пакеты. VLAN'ы. LACP 
## Описание домашнего задания:

[Методичка](https://docs.google.com/document/d/1BO5cUT0u4ABzEOjogeHyCaNiYh76Bh73/edit)

Что нужно сделать?

- в Office1 в тестовой подсети появляется сервера с доп интерфесами и адресами
- в internal сети testLAN

testClient1 - 10.10.10.254

testClient2 - 10.10.10.254

testServer1- 10.10.10.1

testServer2- 10.10.10.1

- развести вланами

testClient1 <-> testServer1

testClient2 <-> testServer2

- между centralRouter и inetRouter "пробросить" 2 линка (общая inernal сеть) и объединить их в бонд

проверить работу c отключением интерфейсов

![37](https://github.com/root40reg/Otus-Linux/assets/132127335/7404cdd6-55e1-4004-9130-ffb8e23866bc)


## Инструкция по выполнению

### Проверка LACP

```
vagrant up
vagrant ssh inetRouter

ping 192.168.255.2
```
```
vagrant ssh centralRouter
sudo -i
ip link set down eth1 (ping продолжает работать)
ip link set down eth2 (ping пропадает)
ip link set up eth1 (ping восстанавливается)
```
