# 38. LDAP. Централизованная авторизация и аутентификация 
## Описание домашнего задания:
Описание домашнего задания
1) Установить FreeIPA
2) Написать Ansible-playbook для конфигурации клиента

Дополнительное задание

3)* Настроить аутентификацию по SSH-ключам

4)** Firewall должен быть включен на сервере и на клиенте

## Инструкция по выполнению
```
vagrant up
vagrant ssh ipa.otus.lan
sudo -i
sh /root/ipa-server.sh # говорим no и затем yes
kinit admin
ipa user-add otus1 --first=Otus --last=User --password
```
Запускаем playbook для клентских ВМ
```
ansible-playbook -i playbooks/hosts playbooks/ipacl.yaml
```
Заходим на client1
```
vagrant ssh client1.otus.lan
sudo -i
kinit otus1
123
# меняем на новый пароль(12345678)
```

Заходим на client2
```
vagrant ssh client2.otus.lan
sudo -i
kinit otus1
```
