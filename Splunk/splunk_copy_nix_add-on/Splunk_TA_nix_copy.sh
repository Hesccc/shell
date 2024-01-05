#!/bin/bash
#
#date：2020/05/20 10:52:39
#author：hesc

export SPLUNK_PATH="/opt/splunk/etc/deployment-apps"
#读取ip.csv文件,获取ip信息
while read ip;do
ip=`echo $ip | sed "s#\.#_#g"`
APPNAME=$ip"_Splunk_TA_nix"
indexName=$ip"_linux"

   #判断IP_Splunk_TA_nix是否存在
   if [ ! -d "$SPLUNK_PATH/$APPNAME" ];then
      cp -r $SPLUNK_PATH/Splunk_TA_nix $SPLUNK_PATH/$APPNAME
      #修改inputs.conf配置文件
      sed -i "s#index = linux#index = $indexName#g" $SPLUNK_PATH/$APPNAME/local/inputs.conf
      echo $SPLUNK_PATH/$APPNAME"->创建完成!" 
   else
      echo $SPLUNK_PATH/$APPNAME"->已存在."
   fi
done < ip.csv
