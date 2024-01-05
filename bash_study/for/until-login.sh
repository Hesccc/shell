#!/bin/bash
#
until who | grep "hsc" ; do
	echo "`date +"%Y-%m-%d %H-%M-%S"`；hsc用户没有登录！"
	#statements
	sleep 5
done
	echo "`date +"%Y-%m-%d %H-%M-%S"`；hsc用户已登录！"
	#echo "`date +"%Y-%m-%d %H-%M-%S"`；hsc用户已登录" >> /opt/hsc-login.log