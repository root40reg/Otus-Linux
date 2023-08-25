
#!/bin/bash
MYBASH=/home/vladimir/Otus-Linux/10
lock_file=$MYBASH'/filebash.lock'
date1=$(date +%y%m%d-%H%M%S)
access_log=$MYBASH/access.log
log_date=$MYBASH'/log-'$date1'.txt'

if [ -f "$lock_file" ]; then
  echo "Процесс уже запущен"
  exit 1
fi
read BASH1 < $MYBASH/temp.txt

touch $lock_file

echo >> $log_date
echo "Диапазон анализа лог-файла" >> $log_date
echo "------------" >> $log_date
cat $access_log | sed -n $BASH1,'$p' | awk '{print $4}' | cut -c 2-| sed -n '1p;$p' >> $log_date
cat $access_log | sed -n $BASH1,'$p' | awk '{print $4}' | cut -c 2-| sed -n '1p;$p' >> $MYBASH/date_temp
echo >> $log_date

echo "Список IP адресов (с наибольшим кол-вом запросов)" >> $log_date
echo "------------" >> $log_date
cat $access_log | sed -n $BASH1,'$p' | awk '{print $1}' | sort |uniq -c |sort -nr |head -n 10 >> $log_date

echo >> $log_date
echo "Список запрашиваемых URL (с наибольшим кол-вом запросов)" >> $log_date
echo "------------" >> $log_date
cat $access_log | sed -n $BASH1,'$p' | awk '{print $11}' | grep http* |sort |uniq -c |sort -nr |head -n 10 >> $log_date

echo >> $log_date
echo "Ошибки веб-ервера/приложения" >> $log_date
echo "------------" >> $log_date
cat $access_log | sed -n $BASH1,'$p' | awk '{print $9}' |grep '[3**,4**,5**]' |sort |uniq -c |sort -nr >> $log_date

echo >> $log_date
echo "Список всех кодов HTTP ответа" >> $log_date
echo "------------" >> $log_date
cat $access_log | sed -n $BASH1,'$p' | awk '{print $9}' |grep '[1-5]' | sort |uniq -c |sort -n -r >> $log_date

BASH1=$(sed -n '$=' $access_log)
BASH1=$((BASH1 + 1))
echo "$BASH1" > $MYBASH/temp.txt
date_t=$(cat $MYBASH/date_temp)

echo 'Log-файл с сервера nginx за период ' $date_t | mail -s 'Server Admin nginx' -A $log_date email@example.ru

rm $lock_file
rm $MYBASH/date_temp
