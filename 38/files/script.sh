timedatectl set-timezone Europe/Moscow
systemctl enable chronyd
#Выключим Firewall:
systemctl stop firewalld
#Отключим автозапуск Firewalld:
systemctl disable firewalld
#Остановим Selinux:
setenforce 0
sysctl -p /etc/sysctl.conf
