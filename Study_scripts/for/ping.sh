#!/bin/bash
#
for (( i = 1; i <= 255; i++ )); do
	ping -c 1 -W 0.1 140.207.23.$i &> /dev/null
	RETVAL=$?
	#echo $RETVAL
	if [ $RETVAL -eq 0 ];then
		echo -e "\033[32m $i \033[0m is up！"
	elif [ $RETVAL -ne 0 ];then
		echo -e "\033[31m $i \033[0m is down!"
	fi
done
