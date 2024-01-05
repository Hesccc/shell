#!/bin/bash
#
declare -i MAX=0
declare -i MIN=0

for I in {1..10};do
#将随机数赋值给myrand变量
 MYRAND=$RANDOM
 if [ $I -le 9 ];then
 [ $I -eq 1 ] && MIN=$MYRAND
#显示myrand的值
   echo -n "$MYRAND,"
 else
#显示myrand的值
   echo "$MYRAND"
fi
#当myrand大于MAX时,将myrand赋值给MAX变量
 [ $MYRAND -gt $MAX ] && MAX=$MYRAND 
 [ $MYRAND -le $MIN ] && MIN=$MYRAND
# if [ $MYRAND -gt $MAX ];then
#  $MAX=$MYRAND
# fi
done
echo $MAX,$MIN
