#!/bin/bash
#
read -p "请输入两个数据,请用空格分隔：" A B
[ -z $A ] && A=100
[ -z $B ] && B=1000
echo "$A+$B=$[$A+$B]"