#!/bin/bash
timestamp=`date +%s`
#获取时间,保存到变量$timestamp
file=/tmp/.iostatinfo
#创建/tmp/.iostatinfo文件
iostat -x 1 1|tail -n +7|head -n -1 > $file
#iostat -x内容保存到/tmp/.iostatinfo
sed -i "s#^#$timestamp #g" $file
#字符拼接 >保存到$file 变量中

cat $file
#打印变量$file的值