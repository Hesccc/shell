#!/bin/bash
#

for file_name in /mnt/hgfs/Bash_Script/*.sh;do 
	echo $file_name
	echo "正在打包中------------"
done

tar -zcvf $file_name Bash_Script.tar.gz