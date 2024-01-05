#!/bin/bash
timestamp=`date +%s`
file=/tmp/.fstabinfo
cat /etc/fstab |grep -v ^#|grep -v swap|grep -v ^$|awk '{print $2}' > $file
sed -i "s#^#$timestamp fstab #g" $file
file2=/tmp/.dfinfo
df -lh|grep -v tmpfs|tail -n +2|awk '{print $NF}' > $file2
sed -i "s#^#$timestamp df #g" $file2
cat $file $file2
