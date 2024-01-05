#!/bin/bash

for i in {1..10}; do
 if id user$i &> /dev/null;then
  echo "USER$i 已存在"
 else 
 useradd user$i
 echo user$i | passwd --stdin user$i &> /dev/null
 echo "已经创建好USER$i"
fi
done
