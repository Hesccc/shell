#!/bin/bash
#

read -p "请输入需要转换的字符：" STRING
until [ $STRING == quit ]; do
	echo $STRING |tr a-z A-Z
	read -p "请再次输入需要转换的字符：" STRING
done