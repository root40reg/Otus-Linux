sudo -i
mkdir /var/backup
mount -v /dev/sda2 /var/backup
chown borg:borg /var/backup/
su - borg
mkdir .ssh
touch .ssh/authorized_keys
chmod 700 .ssh
chmod 600 .ssh/authorized_keys

