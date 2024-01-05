#!/bin/bash
#
declare -i I=0
cat << EOF
d|D) 查看硬盘情况.
m|M）查看内存使用情况.
s|S) 查看交换空间使用情况.
q|Q) 退出系统.
*) 退出.
EOF
echo -n -e "\033[5;37;41m请输入你的选项:\033[0m"
read CHOOSE
while [ $CHOOSE != 'quit' ];do
case $CHOOSE in
d|D)
	df -Ph;;
m|M)
	free -h|grep "Mem";;
s|S)
	free -h|grep "Swap";;
*)
	echo "错误参数."
esac
echo -n -e "\033[5;37;41m请输入你的选项:\033[0m"
read CHOOSE
done