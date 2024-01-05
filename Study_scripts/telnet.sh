#!/bin/bash
#


#for (( i = 1; i <= 65536; i++ )); do
#	nc -w 1 47.52.198.89 $i &> /dev/null
#	RETVAL=$?
#	#echo $RETVAL
#	if [ $RETVAL -eq 0 ];then
#		echo -e "\033[32m 47.52.198.89 $i \033[0m is up！"
#	elif [ $RETVAL -ne 0 ];then
#		echo -e "\033[31m 47.52.198.89 $i \033[0m is down!"
#	fi
#done

#nc -w 1 -v 47.52.198.89 22
nc -nvz 47.52.198.89 1-65536