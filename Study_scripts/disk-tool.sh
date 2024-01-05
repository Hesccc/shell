#!/bin/bash
#
echo "磁盘情况如下："
fdisk -l 2> /dev/null | grep "^Disk /dev/[sh]d[a-z]" | awk '{print $1,$2,$3,$4}'
fdisk -l 2> /dev/null | grep "^磁盘 /dev/[sh]d[a-z]" | awk '{print $1,$2,$3,$4}'
read -p "请选择你要操作的硬盘(输入磁盘名称如：sda)/quit:为退出：" Disk_name
if [ $Disk_name = quit ]; then
	echo "正在退出"
	exit 0
fi
ls /dev/$Disk_name &> /dev/null
RETVAL=$?
while [ $RETVAL -ne 0 ]; do
	echo -n "您选择的硬盘不存在,请重新选择："
	read Disk_name
	ls /dev/$Disk_name &> /dev/null
	RETVAL=$?
done
echo "你选择的硬盘为/dev/$Disk_name"
echo -n -e "\033[41;37m此操作可能会损坏数据,请谨慎操作!是否继续?\033[0m[y/n]:" 
read operation 
if [ $operation = y ]; then
	dd if=/dev/zero of=/dev/$Disk_name bs=512 count=1 #抹除分区
	sync #将内存缓冲区内的数据写入磁盘
	partprobe #内核重读
	sleep 3
echo 'n
p
1

+20M
n
p
2

+512M
n
p
3

+128M
t
3
82
w' | fdisk /dev/$Disk_name

mkfs.ext4 /dev/${Disk_name}1
mkfs.ext4 /dev/${Disk_name}2
mkswap /dev/${Disk_name}3
elif [ $operation = n ]; then
	echo "正在退出"
	exit 0
fi


