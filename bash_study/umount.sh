#！/bin/bash
#
read -p "请输入你需要卸载的分区：" DISK_NAME


for i in `mount |grep "^/dev/${DISK_NAME}[1-9]" |awk '{print $1}'`; do
	echo $i
 	kuser -km $i
 	umount $i
done


