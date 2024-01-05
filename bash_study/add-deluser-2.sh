#!/bin/bash
#

if [ $# -lt 1 ];then
 echo "你必须传递参数!"
 exit 7
fi

if [ $1 == '--add' ];then 
 for I in `echo $2 | sed 's/,/ /g'`; do
   if id $I &> /dev/null;then
     echo "$I 已存在!"
   else
     useradd $I
     echo $I|passwd --stdin $I &> /dev/null
     echo "已创建好$I用户!"
    fi 
 done
elif [ $1 == '--del' ];then
  for I in `echo $2 | sed 's/,/ /g'`;do
    if id $I &>  /dev/null;then
      	userdel -r $I
	echo "已将$I用户删除"
    else 
	echo "用户$I不存在!"
    fi
  done
elif [ $1 == '--help' ];then
  echo "使用帮助："
  echo "新增用户：--add user1,user2,user3..."
  echo "删除用户：--del user1,user2,user3..."
else
  echo "你输入的参数错误!"
  echo "可以使用--help获取帮助"
  exit 1
fi 
