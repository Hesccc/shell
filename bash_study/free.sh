#/bin/bash
timestamp=`date +%s`
file=/tmp/.freeinfo 
free -m|tail -n +2 > $file
sed -i "s#^#$timestamp #g" $file
cat $file
