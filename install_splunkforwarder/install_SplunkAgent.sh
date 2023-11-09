#!/bin/bash
#
# Time     : 2022/10/13 16:31:50
# Author   : Hesc
# Version  : 1.7
# Describe : 删除在线下载安装方法
# Describe : 添加ping DS IP检测
# Describe : 9.1.1版本使用systemct进行管理，调整设置开机自启动顺序

# 公共区DS服务器IP地址
DS_IP="10.1.22.127"

# SPLUNKFORWARDER_URL="http://$IP/splunk/splunkforwarder-9.1.1-64e843ea36b1-Linux-x86_64.tgz"
# FORWARDER_MANAGE_PORT_URL="http://$IP/splunk/org_all_forwarder_manageport.tgz"  # forwarder_manageport 设置agent管理端口为29768
# DEPLOYMENTCLIENT_URL="http://$IP/splunk/org_public_deploymentclient.tgz"

SPLUNKFORWARDER="/opt/splunkforwarder-9.1.1-64e843ea36b1-Linux-x86_64.tgz"
DEPLOYMENTCLIENT="/opt/org_public_deploymentclient.tgz"
FORWARDER_MANAGE_PORT="/opt/org_all_forwarder_manageport.tgz"

# splunkforwarder安装目录
SPLUNK_HOME="/opt/splunkforwarder"

# 检查Splunk Agent是否运行
SPLUNKFORWARDER_PID=$(ps -ef|grep splunk | grep -v grep | awk '{print $2}') 

# log time
TIME=$(date +"%F %T")

function install() {

	# 下载相关安装包，删除在线安装方式

	# echo -e "\033[42;30m$TIME INFO: Download Splunk Agent Install Package.\033[0m"
	# curl -o $SPLUNKFORWARDER $SPLUNKFORWARDER_URL   					   
	# curl -o $DEPLOYMENTCLIENT $DEPLOYMENTCLIENT_URL
	# curl -o $FORWARDER_MANAGE_PORT $FORWARDER_MANAGE_PORT_URL

	if [ -f "$SPLUNKFORWARDER" -a -f "$DEPLOYMENTCLIENT" -a -f "$FORWARDER_MANAGE_PORT" ]; then # 判断相关的安装包是否存在
		echo -e "\033[42;30m$TIME INFO: Start Install splunkforwarder.\033[0m" # 开始安装splunkforwarder
		tar -zxf $SPLUNKFORWARDER -C /opt  
		tar -zxvf $DEPLOYMENTCLIENT -C $SPLUNK_HOME/etc/apps
		tar -zxvf $FORWARDER_MANAGE_PORT -C $SPLUNK_HOME/etc/apps
		
		chown -R root:root $SPLUNK_HOME  # 设置Splunkforwarder安装目录属主:属组
		
		# 设置开机启动
		echo -e "\033[42;30m$TIME INFO: Set splunkforwarder service boot-start.\033[0m"
		$SPLUNK_HOME/bin/splunk enable boot-start --accept-license --answer-yes --no-prompt --gen-and-print-passwd  
		
		# 启动splunkforwarder服务
		echo -e "\033[42;30m$TIME INFO: start Splunkforwarder service.\033[0m"
		$SPLUNK_HOME/bin/splunk start  
		
		# 删除临时文件
		rm -rf $SPLUNKFORWARDER           
		rm -rf $DEPLOYMENTCLIENT
		rm -rf $FORWARDER_MANAGE_PORT
		check
	else
		echo -e "\033[41;30m$TIME ERROR: $splunkforwarder,$org_public_deploymentclient or $org_all_forwarder_manageport file does not exist, The script exits! Please contact the Splunk team.\033[0m"
		exit 8
	fi
}

function check(){
	sleep 2.5
	SPLUNK_STATUS=$($SPLUNK_HOME/bin/splunk status|grep "splunkd is not running.")

	# 判断SPLUNK_STATUS长度是否为零：为零->true 非零->false 
	if [ -z "$SPLUNK_STATUS" ];then
		echo -e "\033[42;30m======================================================\033[0m"
		echo -e "\033[42;30m$TIME INFO: Beautiful!! Splunk Agent install successfully!\033[0m"
		echo -e "\033[42;30m$TIME INFO: Check Splunk Agent Status:\033[0m"
		# 查看splunkforwarder服务状态
		$SPLUNK_HOME/bin/splunk status
		rm -rf /opt/install_SplunkAgent.sh
		exit 0
	else
		echo -e "\033[41;30m$TIME ERROR: Splunk Agent service startup failed,Please contact the Splunk team.\033[0m"
		rm -rf /opt/install_SplunkAgent.sh
		exit 8
	fi
}

function main(){
	ping -c 1 $DS_IP 
	if [ $? -eq 0 ]; then  # 检查网络连通性
		echo -e "\033[42;30m$TIME INFO: Ping $IP success.\033[0m"
		if [ -z "$SPLUNKFORWARDER_PID" ]; then
			install
		else
			echo -e "\033[41;30m$TIME ERROR: Splunk Agent has been install and is being reinstalled.\033[0m"
			echo -e "\033[42;30m$TIME INFO: Stop the Splunk agent service.\033[0m"
			$SPLUNK_HOME/bin/splunk stop
			echo -e "\033[42;30m$TIME INFO: Delete Splunk Agent install the directory.\033[0m"
			echo "rm -rf $SPLUNK_HOME"
			rm -rf $SPLUNK_HOME
			install
		fi
	else
		echo -e "\033[41;30m$TIME ERROR: Ping $IP fail,The script exits! Please contact the Splunk team.\033[0m"
		exit 8
	fi
}

main