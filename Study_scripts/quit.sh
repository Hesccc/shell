#!/bin/bash
#
#echo $1

if [ $1 == 'Q' -o $1 == 'q' -o $1 == 'quit' -o $1 == 'Quit' ];then
 echo "正在退出sh脚本。。。"
 exit 0
else 
 echo "无效命令！"
 exit 1
fi
