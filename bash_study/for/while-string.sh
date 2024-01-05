#!/bin/bash
#
read -p "请输入要装换的单词：" STRING
if [ -n "$STRING" ]; then
 while [ $STRING != 'quit' ]; do
	echo $STRING|tr 'a-z' 'A-Z'
	read -p "再次输入要装换的单词：" STRING
	#statements
done
else
	echo "你输入的值长度为0."
	exit 7
fi
