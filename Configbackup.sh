#!/bin/bash
echo "$(date +"%Y/%m/%d %H:%M:%S") configuration backup start" >> Configbackup.log
cat /home/handyman/Configbackup/list | while read i
do 
ip_addr=$(echo $i|awk -F' ' '{print $1}')
ping -c 3 -W 1 $ip_addr &> \dev\null
if [ $? -eq 0 ]
then
expect Configbackup.tcl $i
else
echo "$(date +"%Y/%m/%d %H:%M:%S") $ip_addr connect failure" >> /home/handyman/Configbackup/Configbackup.log
fi
done
echo "$(date +"%Y/%m/%d %H:%M:%S") configuration backup finish" >> /home/handyman/Configbackup/Configbackup.log

