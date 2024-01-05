#!/bin/bash
timestamp=`date +%s`
file=/tmp/.inodeinfo
df -i|tail -n +2|grep -v tmpfs > $file
sed -i "s#^#$timestamp #g" $file
cat $file
