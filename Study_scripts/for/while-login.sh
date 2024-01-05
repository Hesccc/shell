#!/bin/bash
#
who |grep "hsc" &> /dev/null
RETVAL=$?

while [ 0 -eq 0 ]; do
	who |grep "hsc" &> /dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ];then
		echo "`date +"%Y-%m-%d %H-%M-%S"`；hsc用户已登录！"
		echo "`date +"%Y-%m-%d %H-%M-%S"`；hsc用户已登录" >> /opt/hsc-login.log
	elif [ $RETVAL -ne 0 ];then
		echo "`date +"%Y-%m-%d %H-%M-%S"`；hsc用户没有登录!"
		echo "`date +"%Y-%m-%d %H-%M-%S"`；hsc用户没有登录" >> /opt/hsc-nologin.log
	fi
	sleep 1
done
if [ $RETVAL -eq 0 ];then 
	echo "hsc用户已登录。"
fi