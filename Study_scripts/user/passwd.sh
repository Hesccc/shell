#!/bin/bash
#

ZIP_DA=`find $SITE -name *zip`
until [ $ZIP_DA ] ; do
	echo -e "\033[41;37moracleappes文件夹缺少Oracle安装包\033[0m" 
	ZIP_DA=`find $SITE -name *zip`
	sleep 1.5
done