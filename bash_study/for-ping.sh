#!/bin/bash
#
for (( i = 1; i <= 255; i++ )); do
	ping -c 1 -W 2 101.132.171.$i &> /dev/null
	RETVAL=$?
	#echo $RETVAL
	if [ $RETVAL -eq 0 ];then
		echo -e "\033[32m 101.132.171.$i \033[0m is up！"
	elif [ $RETVAL -ne 0 ];then
		echo -e "\033[31m 101.132.171.$i \033[0m is down!"
	fi
done

'''for (( i = 1; i <= 255; i++ )); do
	for (( j = 0; j <= 255; j++ )); do
		for (( k = 0; k <= 255; k++ )); do
			for (( l = 1; l <= 255; l++ )); do
				echo $i.$j.$k.$l >> /opt/ipaddr.txt
				#ping -c 1 -W 2 101.132.171.$i &> /dev/null
			done
		done
	done
done'''