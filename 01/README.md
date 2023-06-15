# 01. С чего начинается Linux </h2>

## Обновление ядра

Берём Vagrantfile из методички, меняем параметры

```
:box_name => "centos/stream8",
:cpus => 1,
:memory => 1024,
```
на 
```
:box_name => "generic/centos8s",
:cpus => 2,
:memory => 2048,
```       
удаляем параметр
```
:box_version => "20210210.0",
```  
Создадим ВМ, запустим и проверим версию ядра
```
vagrant up
vagrant ssh

[vagrant@kernel-update ~]$ uname -r
4.18.0-448.el8.x86_64

sudo yum install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
sudo yum --enablerepo elrepo-kernel install kernel-ml -y

sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grub2-set-default 0
sudo reboot
```
После перезагрузки снова проверяем версию ядра и удаляем ВМ
```
vagrant ssh
[vagrant@kernel-update ~]$ uname -r
6.3.7-1.el8.elrepo.x86_64

exit
vagrant destory —-force
```

## Создание образа системы

### Создаем структуру каталогов и файлов из методички
```
packer/
├── centos.json
├── http
│   └── ks.cfg
├── scripts
│   ├── stage-1-kernel-update.sh
│   └── stage-2-clean.sh
```

Важные моменты:

В файле centos.json меняем параметры
```
ssh_timout: 20m
"iso_checksum": "b4bb35e2c074b4b9710419a9baa4283ce4a02f27d5b81bb8a714b576e5c2df7a",
"iso_url": "http://mirror.linux-ia64.org/centos/8-stream/isos/x86_64/CentOS	-Stream-8-x86_64-20230209-boot.iso",
"execute_command": "{{.Vars}} sudo -S -E bash '{{.Path}}'",
"vboxmanage": [
        [
          "modifyvm",
          "{{.Name}}",
          "--memory",
          "1024"
        ],

```
на 
```
ssh_timout: 60m
"iso_checksum": "a3b9337647b43a600f6ae1f1cff44d750313f2357b7ac41337a594d3720584b2",
"iso_url": "http://mirror.softaculous.com/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-20230119-boot.iso",
"execute_command":  "echo 'vagrant'| sudo -S -E bash '{{.Path}}'",
"vboxmanage": [
        [
          "modifyvm",
          "{{.Name}}",
          "--memory",
          "2048"
        ],
```
   
Запускаем установку
```
packer build centos.json
```
Во время установки необходимо пару раз подтвердить действия в консоли ВМ.

Если исполнение второго скрипта stage-2-clean.sh зависнит на этапе Gracefully halting, можно просто выключить ВМ через VirtualBox и выполнение продолжится. Альтернативно можно во второй скрипт добавить команду ```shutdown -r now``` и перезаустить установку.

После завершения установки появится файл образа системы ```centos-8-kernel-6-x86_64-Minimal.box```

Запустим созданный образ
```
vagrant box add centos8-kernel5 centos-8-kernel-6-x86_64-Minimal.box
vagrant box list
vagrant init centos8-kernel5

vagrant up
vagrant ssh
[vagrant@otus-c8 ~]$ uname -r
6.3.8-1.el8.elrepo.x86_64

exit
vagrant destroy --force
```
Зальём готовый образ на Vagrant
```
vagrant cloud auth login --token <token>
vagrant cloud publish --release root40reg/centos8-kernel5 1.0 virtualbox centos-8-kernel-5-x86_64-Minimal.box

vagrant init root40reg/centos8-kernel5
```
Если после запуска ВМ появится сообщение ```default: Warning: Authentication failure. Retrying...``` нажать ```CTRL+C```, далее ```vagrant ssh``` и ввести пароль от ВМ
```
[vagrant@otus-c8 ~]$ uname -r
6.3.8-1.el8.elrepo.x86_64
exit
vagrant destroy --force
```

