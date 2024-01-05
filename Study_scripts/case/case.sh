#!/bin/bash
#
#$1=$xz
case $1 in 
[1-9])
	echo "你输入的值为$1" ;;
[a-z])
	echo "你输入的值为$1" ;;
[A-Z])
	echo "你输入的值为$1" ;;
*)
	echo "全部"
esac   
