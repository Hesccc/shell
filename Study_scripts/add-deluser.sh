#!/bin/bash
#

if [ $# -lt 1 ];then
 echo "你必须给定参数!"
 exit 7
fi
if [ $1 == '--add' ];then 
 for i in {1..10};do
  if id user$i &> /dev/null; then
   echo "user$i已存在"
  else
   useradd user$i
   echo user$i|passwd --stdin user$i &> /dev/null
fi
done
elif [ $1 == '--del' ];then
 for i in {1..10};do
  if id user$i &> /dev/null;then
  userdel -r user$i
  echo "已删除!user$i用户"
  else
  echo "user$i 不存在!"
fi
done
else 
 echo "你输入的选项不错误！"
 exit 8
fi
