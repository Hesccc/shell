#!/bin/bash
#

for i in {1..10};do
	if id user$i &> /dev/null;then
		userdel -r user$i 
		echo "已经删除user$i"
	else 
		echo "user$i 不存在"
fi
#结束for循环
done
