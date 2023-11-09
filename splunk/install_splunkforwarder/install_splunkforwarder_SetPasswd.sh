#!/bin/sh
#
# Creation time : 2021年9月28日 10:04:50
# Version : 1.2 
# Founder : Hesc
# 设置自定义密码

# pwd 路径
PWD_DIR=`pwd`
echo $PWD_DIR

# Splunkforwarder installation path
INSTALL_DIR="/opt"

# Splunkforwarder installation package path
INSTALL_FILE="$PWD_DIR/splunkforwarder-8.2.0-e053ef3c985f-Linux-x86_64.tgz"

# Download the splunkforwarder installation package using wget
# copy and paste your wget command between the ""
WGET_CMD="wget -O splunkforwarder-7.1.2-a0c72a66db66-Linux-x86_64.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=7.1.2&product=universalforwarder&filename=splunkforwarder-7.1.2-a0c72a66db66-Linux-x86_64.tgz&wget=true'"

# Set the deployment server information
# Used to manage splunkforwarder
# Example 1.2.3.4:8089
DEPLOY_SERVER="10.21.208.18:8089"

# Set the Splunk admin password
PASSWORD="splunk@123"

REMOTE_SCRIPT="
tar -zxvf $INSTALL_FILE -C $INSTALL_DIR
echo \"[user_info]
USERNAME = admin
PASSWORD = $PASSWORD\" > $INSTALL_DIR/splunkforwarder/etc/system/local/user-seed.conf
echo \"[target-broker:deploymentServer]
targetUri = $DEPLOY_SERVER\" > /opt/splunkforwarder/etc/system/local/deploymentclient.conf
$INSTALL_DIR/splunkforwarder/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt
sudo $INSTALL_DIR/splunkforwarder/bin/splunk enable boot-start
"

# 判断安装包是否存在
if [ -f $INSTALL_FILE ]; then
	if [ ! -d $INSTALL_DIR/splunkforwarder ]; then
		echo "====The $INSTALL_FILE File exists===="
		echo "====In 5 Seconds starts install===="
		echo
		echo "================================"
		echo "$REMOTE_SCRIPT"
		echo "================================"
		echo
		sleep 5
		echo "====Start install Running===="
		echo
		tar -zxvf $INSTALL_FILE -C $INSTALL_DIR
		echo "[user_info]
USERNAME = admin
PASSWORD = $PASSWORD" > $INSTALL_DIR/splunkforwarder/etc/system/local/user-seed.conf
		echo "[target-broker:deploymentServer]
targetUri = $DEPLOY_SERVER" > /opt/splunkforwarder/etc/system/local/deploymentclient.conf
		echo
		echo "====Splunkforwarder Start===="
		echo
		$INSTALL_DIR/splunkforwarder/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt
		echo
		echo "====Splunkforwarder Set boot-start up===="
		echo
		sudo $INSTALL_DIR/splunkforwarder/bin/splunk enable boot-start
		echo
		echo "========================================"
		echo "Splunkforwarder The install is complete!"
		echo "========================================"
		echo
		exit 0
	fi
	echo "ERROR:/opt/splunkforwarder directory existing!"
	exit 8
fi
echo "ERROR:The $INSTALL_FILE is no!"
exit 8