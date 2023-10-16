#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8
SCRIPTS_PATH=$(cd "$(dirname "$0")"; pwd)  # 获取脚本保存的路径
SCRIPTS_NAME=`basename $0`  # 获取脚本名称

function check(){
    # 判断运行的权限是否为root权限
    if [ $(whoami) = "root" ];then
        echo -e "\033[42;30m##$(date +"%F %T") INFO: 通过! 脚本使用root权限运行.\033[0m"
    else
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: 请使用root权限执行<$SCRIPTS_NAME>脚本\033[0m"
        exit 1;
    fi

    # 判断/etc/redhat-release配置文件是否存在
    if [ -f /etc/redhat-release ];then
        echo -e "\033[42;30m##$(date +"%F %T") INFO: 通过! 当前操作系统为(CentOS | Red Hat).\033[0m"
    else
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: <$SCRIPTS_NAME>只支持CentOS|Red Hat操作系统上运行\033[0m"
        exit 1;
    fi

    # 判断syslog-ng文件夹是否存在
    if [ -d $SCRIPTS_PATH/syslog-ng ];then
        echo -e "\033[42;30m##$(date +"%F %T") INFO: 通过! $SCRIPTS_PATH/syslog-ng目录存在.\033[0m"
    else
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: $SCRIPTS_PATH/syslog-ng 目录不存在!!!请仔细检查!\033[0m"
        exit 1;
    fi

    # 判断splunk相关文件是否存在
    if [ -d $SCRIPTS_PATH/splunk ];then
        echo -e "\033[42;30m##$(date +"%F %T") INFO: 通过! $SCRIPTS_PATH/splunk目录存在.\033[0m"
    else
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: $SCRIPTS_PATH/splunk目录不存在!!! 请仔细检查!\033[0m"
        exit 1;
    fi
    echo "========================================================================================================"
    echo
    install_syslog_ng
    sleep 5
    install_splunk
}

# Install Syslog_ng function
function install_syslog_ng(){
README_SYSLOGNG_SCRIPT="
\n 
# 停止rsyslog 服务 \n
systemctl stop rsyslog \n
systemctl disable rsyslog \n

# 开始安装syslog-ng软件包 \n
rpm -ivh $SCRIPTS_PATH/syslog-ng/pkgs/eventlog-0.2.13-4.el7.x86_64.rpm \n
rpm -ivh $SCRIPTS_PATH/syslog-ng/pkgs/ivykis-0.36.2-2.el7.x86_64.rpm \n
rpm -ivh $SCRIPTS_PATH/syslog-ng/pkgs/libnet-1.1.6-7.el7.x86_64.rpm \n
rpm -ivh $SCRIPTS_PATH/syslog-ng/pkgs/syslog-ng-3.5.6-3.el7.x86_64.rpm \n

# 复制syslog-ng配置文件 \n
cp $SCRIPTS_PATH/syslog-ng/conf/r.conf /etc/syslog-ng/conf.d \n

# 启动syslog-ng 服务 \n
systemctl start syslog-ng \n
systemctl enable syslog-ng \n
systemctl status syslog-ng \n

# 检查syslog-ng 启动端口 \n
ss -tlunp|grep 514 \n

# 创建syslog日志保存目录 \n
mkdir -p /opt/logs \n

# 创建删除syslog日志定时计划 \n
cp $SCRIPTS_PATH/syslog-ng/clear_expired_logs.sh /opt/logs/clear_expired_logs.sh \n
echo \"30 1 \* \* \* /opt/logs/clear_expired_logs.sh\" >> /var/spool/cron/root \n
"
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 开始安装syslog-ng Server\033[0m"
    echo "========================================================================================================"
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 暂停5秒,将执行以下命令完成syslog-ng安装,可使用Ctrl+Z退出安装\033[0m"
    echo "========================================================================================================"
    echo -e $README_SYSLOGNG_SCRIPT
    sleep 5

    # 停止rsyslog服务并关闭rsyslog开机自启动
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 停止rsyslog服务并关闭rsyslog开机自启动\033[0m"
    systemctl stop rsyslog
    systemctl disable rsyslog

    # 安装syslog-ng
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 开始安装syslog-ng\033[0m"
    SYSLOGNG_INSTALL_STATUS=$(rpm -qa|grep syslog-ng-3.5.6-3.el7.x86_64)
    if [ -z $SYSLOGNG_INSTALL_STATUS ];then
        rpm -ivh $SCRIPTS_PATH/syslog-ng/pkgs/eventlog-0.2.13-4.el7.x86_64.rpm
        rpm -ivh $SCRIPTS_PATH/syslog-ng/pkgs/ivykis-0.36.2-2.el7.x86_64.rpm
        rpm -ivh $SCRIPTS_PATH/syslog-ng/pkgs/libnet-1.1.6-7.el7.x86_64.rpm
        rpm -ivh $SCRIPTS_PATH/syslog-ng/pkgs/syslog-ng-3.5.6-3.el7.x86_64.rpm
    else
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: $SYSLOGNG_INSTALL_STATUS 已安装,跳过syslog-ng安装\033[0m"
        rpm -qa|grep -E "syslog-ng-3.5.6-3.el7.x86_64|eventlog-0.2.13-4.el7.x86_64|ivykis-0.36.2-2.el7.x86_64|libnet-1.1.6-7.el7.x86_64"
    fi

    # 创建syslog-ng配置文件
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 复制$SCRIPTS_PATH/syslog-ng/conf/r.conf to /etc/syslog-ng/conf.d\033[0m"
    if [ -f /etc/syslog-ng/conf.d/r.conf ];then
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: /etc/syslog-ng/conf.d/r.conf>配置文件已存在,跳过复制\033[0m"
    else
        cp $SCRIPTS_PATH/syslog-ng/conf/r.conf /etc/syslog-ng/conf.d
    fi
    
    # 启动syslog-ng服务
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 启动syslog-ng服务\033[0m"
    systemctl start syslog-ng

    # 设置syslog-ng开机自启动
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 设置syslog-ng开机自启\033[0m"
    systemctl enable syslog-ng
    
    # 检查syslog-ng运行状态
    echo "========================================================================================================"
    echo -e "\033[41;30m##$(date +"%F %T") INFO: 重要:检查syslog-ng运行状态是否为:'\033[42;30mactive (running)\033[0m\033[41;30m'\033[0m"
    echo "========================================================================================================"
    systemctl status syslog-ng

    # 检查syslog-ng端口是否打开
    echo "========================================================================================================"
    echo -e "\033[41;30m##$(date +"%F %T") INFO: 重要:检查syslog-ng服务打开端口:'\033[42;30mudp/514|tcp/514\033[0m\033[41;30m'\033[0m"
    echo "========================================================================================================"
    ss -tlunp|grep 514

    # 创建/opt/logs日志保存目录
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 创建/opt/logs目录保存syslog日志\033[0m"
    if [ -e /opt/logs ];then
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: /opt/logs目录已存在,跳过创建\033[0m"
    else
        mkdir -p /opt/logs
    fi

    # 复制clear_expired_logs.sh数据删除脚本到/opt/logs
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 复制clear_expired_logs.sh脚本\033[0m"
    if [ -f /opt/logs/clear_expired_logs.sh ];then
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: /opt/logs/clear_expired_logs.sh配置文件已存在,跳过复制\033[0m"
        ls -l /opt/logs/clear_expired_logs.sh
        echo -e "\033[42;30m##$(date +"%F %T") INFO: clear_expired_logs.sh脚本内容:\033[0m"
        cat /opt/logs/clear_expired_logs.sh
        echo 
    else
        cp $SCRIPTS_PATH/syslog-ng/clear_expired_logs.sh /opt/logs/clear_expired_logs.sh
        ls -l /opt/logs/clear_expired_logs.sh
        cat /opt/logs/clear_expired_logs.sh
    fi
    
    # 创建定时删除/opt/logs定时计划
    echo -e "\033[42;30m##$(date +"%F %T") INFO: 创建clear_expired_logs.sh crontab定时计划\033[0m"

    CRONTAB_STATUS=$(cat /var/spool/cron/root |grep /opt/logs/clear_expired_logs.sh)
    if [ -z "$CRONTAB_STATUS" ];then
        echo "30 1 * * * /opt/logs/clear_expired_logs.sh" >> /var/spool/cron/root
        crontab -l
    else
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: /var/spool/cron/root配置已存在,跳过创建\033[0m"
        crontab -l
    fi

    echo "========================================================================================================"
    echo -e "\033[42;30m##$(date +"%F %T") INFO: Syslog-ng Server安装完成.\033[0m"
    echo "========================================================================================================"
}

# Install Splunk Enterprise function
function install_splunk(){
    SPLUNK_PKGS_FILE="splunk-9.0.4-de405f4a7979-Linux-x86_64.tgz"
    SPLUNK_INSTALL_DIR="/opt"
    SPLUNK_INSTALL_FILE="$SCRIPTS_PATH/splunk/$SPLUNK_PKGS_FILE"
    SPLUNK_HF_OUTPUTS="$SCRIPTS_PATH/splunk/mss_all_heavyforwarder_inputs.tgz"
    SPLUNK_HF_INPUTS="$SCRIPTS_PATH/splunk/mss_all_heavyforwarder_outputs.tgz"
    README_SPLUNK_SCRIPT="
\n # 创建splunk用户和用户组 \n
groupadd -g 10777 splunk \n
useradd -u 10777 -g splunk -d /home/splunk -c \"splunk user\" \n

# 解压splunk安装包 \n
tar -zxvf $SPLUNK_INSTALL_FILE -C $SPLUNK_INSTALL_DIR/splunk/etc/apps \n
tar -zxvf $SPLUNK_HF_OUTPUTS -C $SPLUNK_INSTALL_DIR/splunk/etc/apps \n
tar -zxvf $SPLUNK_HF_INPUTS -C $SPLUNK_INSTALL_DIR/splunk/etc/apps \n
chown -R splunk:splunk $SPLUNK_INSTALL_DIR/splunk/ \n

# 设置splunk admin用户密码 \n
echo \"[user_info] \n
USERNAME = admin \n
PASSWORD = $SPLUNK_HF_ADMIN_PWD\" > $SPLUNK_INSTALL_DIR/splunk/etc/system/local/user-seed.conf \n

# 启动splunk服务 \n
$SPLUNK_INSTALL_DIR/splunk/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt \n

# 设置splunk开机自启动 \n
$SPLUNK_INSTALL_DIR/splunk/bin/splunk enable boot-start \n
"
    # Set the Splunk admin password, ECCOM universal password is "Eccom@123"
    SPLUNK_HF_ADMIN_PWD="Eccom@123"
    
    # Check Splunk Service status
    # 判断 SPLUNK_HF_PID_STATUS 检测字符串长度, 不为0 -> true 为0 -> false
    SPLUNK_HF_PID_STATUS=$(ps -ef|grep splunkd | grep -v grep | awk '{print $2}')

    if [ -z "$SPLUNK_HF_PID_STATUS" ];then
        echo
        echo -e "\033[42;30m##$(date +"%F %T") INFO: 开始安装 Splunk Enterprise\033[0m"
        echo "========================================================================================================"
        echo -e "\033[42;30m##$(date +"%F %T") INFO: 暂停5秒,将执行以下命令完成 Splunk Enterprise 安装,可使用Ctrl+Z退出安装\033[0m"
        echo "========================================================================================================"
        echo -e $README_SPLUNK_SCRIPT
        sleep 5

        # 判断splunk用户组是否创建
        egrep "^splunk" /etc/group >& /dev/null
        if [ $? -ne 0 ];then
            groupadd -g 10777 splunk
        else
            echo "========================================================================================================"
            echo -e "\033[41;30m##$(date +"%F %T") ERROR: splunk用户组已创建,跳过创建\033[0m"
            echo "========================================================================================================"
        fi

        # 判断splunk用户是否创建
        egrep "^splunk" /etc/passwd >& /dev/null
        if [ $? -ne 0 ];then
            useradd -u 10777 -g splunk -d /home/splunk -c "splunk user"
        else
            echo "========================================================================================================"
            echo -e "\033[41;30m##$(date +"%F %T") ERROR: splunk用户已创建,跳过创建\033[0m"
            echo "========================================================================================================"
        fi

        # 判断/opt/splunk目录是否存在 
        if [ -d /opt/splunk ];then
            echo "========================================================================================================"
            echo -e "\033[41;30m##$(date +"%F %T") ERROR: /opt/splunk 目录已存在,尝试启动splunk服务.\033[0m"
            echo "========================================================================================================"
            echo -e "\033[42;30m##$(date +"%F %T") INFO: 启动splunk服务.\033[0m"
            $SPLUNK_INSTALL_DIR/splunk/bin/splunk start
        else
            # 解压splunk 相关软件包
            echo -e "\033[42;30m##$(date +"%F %T") INFO: 解压Splunk Enterprise安装包! 请稍等一会!\033[0m"
            tar -zxf $SPLUNK_INSTALL_FILE -C $SPLUNK_INSTALL_DIR

            tar -zxvf $SPLUNK_HF_OUTPUTS -C $SPLUNK_INSTALL_DIR/splunk/etc/apps
            tar -zxvf $SPLUNK_HF_INPUTS -C $SPLUNK_INSTALL_DIR/splunk/etc/apps

            # 设置/opt/splunk 属主:属组
            chown -R splunk:splunk $SPLUNK_INSTALL_DIR/splunk

            # 设置splunk admin 密码
            echo "[user_info]
            USERNAME = admin
            PASSWORD = $SPLUNK_HF_ADMIN_PWD" > $SPLUNK_INSTALL_DIR/splunk/etc/system/local/user-seed.conf

            # 启动splunk 服务
            $SPLUNK_INSTALL_DIR/splunk/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt

            # 设置splunk 开机自启动
            $SPLUNK_INSTALL_DIR/splunk/bin/splunk enable boot-start

            # 检查splunk 服务状态
            echo -e "\033[42;30m##$(date +"%F %T") INFO: 检查Splunk Enterprise服务启动状态!\033[0m"

            # Check Splunk Service status
            # 判断 SPLUNK_HF_PID_STATUS 检测字符串长度, 不为0 -> true 为0 -> false
            SPLUNK_HF_PID_STATUS=$(ps -ef|grep splunkd | grep -v grep | awk '{print $2}')
            if [ -n "$SPLUNK_HF_PID_STATUS" ];then # 判断SPLUNK_STATUS长度是否为零：为零->true 非零->false 
		        echo "========================================================================================================"
		        echo -e "\033[42;30m##$(date +"%F %T") INFO: Beautiful!! Splunk Enterprise install successfully!\033[0m"
		        echo -e "\033[42;30m##$(date +"%F %T") INFO: Check Splunk Enterprise Status:\033[0m"
                echo "========================================================================================================"
                # 查看 Splunk Enterprise 服务状态
                sleep 3
		        $SPLUNK_INSTALL_DIR/splunk/bin/splunk status
                
                echo -e "\033[42;30m##$(date +"%F %T") INFO: Splunk Enterprise 安装完成，安装信息如下:\033[0m"
                echo "========================================================================================================"
                echo "Url: http://localhost:8000"
                echo "User: admin"
                echo "Password: $SPLUNK_HF_ADMIN_PWD"
                echo "安装路径: $SPLUNK_INSTALL_DIR/splunk/"
                echo "========================================================================================================"
                
                rm -rf $SCRIPTS_PATH
                rm -rf $SCRIPTS_PATH/$SCRIPTS_NAME
		        exit 0
            fi
        fi
    else
        echo -e "\033[41;30m##$(date +"%F %T") ERROR: Splunk Enterprise服务已启动,退出Splunk Enterprise安装!\033[0m"
        rm -rf $SCRIPTS_PATH
        rm -rf $SCRIPTS_PATH/$SCRIPTS_NAME
        exit 1
    fi
}
echo -e "\033[42;30m##$(date +"%F %T") INFO: 安装先决条件检查：\033[0m"
echo "========================================================================================================"
check
