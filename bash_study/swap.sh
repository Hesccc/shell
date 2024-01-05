#!/bin/bash
timestamp=`date +%s`
file=/tmp/.swapinfo
swapon -s|tail -n +2 > $file
sed -i "s#^#$timestamp #g" $file
cat $file
