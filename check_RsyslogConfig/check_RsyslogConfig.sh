#!/bin/bash
RSYSLOG_CONF="/etc/rsyslog.conf"

ping -c 1 66.200.202.151
if [ $? -eq 0 ]; then
    echo "网络通,进行下一步操作.."
else
    echo "网络不通,请开通相关网络策略!"
    exit 8
fi

ls -l $RSYSLOG_CONF
echo "判断$RSYSLOG_CONF""配置文件是否存在...."

if [ -f "$RSYSLOG_CONF" ];then
    echo "$RSYSLOG_CONF""文件存在,开始修改...."
    echo "备份$RSYSLOG_CONF文件为""$RSYSLOG_CONF""_backups"
    cp $RSYSLOG_CONF /etc/rsyslog.conf_backups
    ls -l /etc/rsyslog.conf*
    echo "authpriv.* @66.200.202.151:514" >> $RSYSLOG_CONF
    echo "重启rsyslog服务!"
    systemctl restart rsyslog
else
    echo "$RSYSLOG_CONF配置文件不存在,请检查操作系统是否安装rsyslog!"
fi