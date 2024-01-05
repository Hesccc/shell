#!/bin/bash
#

if [ $# -lt 1 ];then
 echo "请输入值：add或del"
 exit 7
elif [ $1 == 'add' ];then
 for i in {1..10};do
 if id user$i &> /dev/null;then
 echo "创建user$i时出现问题"
 echo "user$i已经存在"	
 else
 useradd user$i -p user$i &>/dev/null
 echo "创建user$i成功！"
 fi
 done
elif [ $1 == 'del' ];then
 for i in  {1..10};do
   if id user$i &> /dev/null;then
     userdel -r user$i 
     echo "已删除user$i用户"
   else 
     echo "用户user$i不存在!"
fi
done
else
  echo "你输入的命令错误：$1重新输入。"
  exit 8	 
fi
