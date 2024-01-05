#!/bin/bash
#

echo -e "\033[41;37m可能会损坏数据,请谨慎操作!\033[0m" 
echo "磁盘情况如下："
fdisk -l 2> /dev/null | grep "^Disk /dev/[sh]d[a-z]" | awk '{print $1,$2,$3,$4}'
fdisk -l 2> /dev/null | grep "^磁盘 /dev/[sh]d[a-z]" | awk '{print $1,$2,$3,$4}'
read -p "请选择你要操作的磁盘：" DISKNAME
if [ $DISKNAME == 'quit' ] ; then
	echo '退出'
	exit 2
fi
until fdisk -l 2> /dev/null |grep -o "^Disk /dev/[sh]d[a-z]" |grep "^Disk /dev/$DISKNAME";do
	read -p "你的输入有误，请重新输入：" DISKNAME
done
echo "你选择的磁盘为：/dev/$DISKNAME"

read -p "是否继续:[y/n]" option

until [ $option == y -o $option == n ] ; do
	read -p "你的输入有误！请重新输入:[y/n]" option
done

if [[ $option == y ]]; then
	#强制卸载挂载点
	for i in `mount |grep "^/dev/${DISKNAME}[1-9]" |awk '{print $1}'`; do
 	fuser -km $i
 	umount $i
	done

	dd if=/dev/zero of=/dev/$DISKNAME bs=512 count=1 &> /dev/null #抹除分区
	sleep 1
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
w' | fdisk /dev/$DISKNAME &> /dev/null #创建分区

	sync &> /dev/null #将内存缓冲区内的数据写入磁盘
	partprobe &> /dev/null #内核重读
	sleep 1
	mkfs.ext4 /dev/${DISKNAME}1 &> /dev/null
	mkfs.ext4 /dev/${DISKNAME}2 &> /dev/null
	mkswap    /dev/${DISKNAME}3 &> /dev/null
	lsblk -f #查看分区情况

elif [ $option == n ] ; then
	echo "退出"
	exit 3
fi