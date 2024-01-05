#!/bin/bash
#
SITE=`find / -name oracleappes`

#oracleappes
until [ "$SITE" ] ; do
	echo -e "\033[41;37m请将oracleappes文件夹上传服务器!\033[0m" 
	SITE=`find / -name oracleappes`
	sleep 1.5
done

#rpm
RPM_DA=`find $SITE -name *rpm`
until [ "$RPM_DA" ] ; do
	echo -e "\033[41;37moracleappes文件夹缺少rpm包\033[0m" 
	RPM_DA=`find $SITE -name *rpm`
	sleep 1.5
done

#oracle zip
ZIP_DA=`find $SITE -name *zip`
until [ "$ZIP_DA" ] ; do
	echo -e "\033[41;37moracleappes文件夹缺少Oracle安装包\033[0m" 
	ZIP_DA=`find $SITE -name *zip`
	sleep 1.5
done

#repo
REPO=`find $SITE -name *repo`
until [ "$REPO" ] ; do
	echo -e "\033[41;37moracleappes文件夹缺少server.repo配置文件\033[0m" 
	REPO=`find $SITE -name *repo`
	sleep 1.5
done

#1.创建Oracle用户和dba,oinstall用户组
#创建dba组
#================dba oinstall Group===========
GROUP_DBA=`sudo cat /etc/group |grep dba |awk -F: '{print $1}'`
if [[ "$GROUP_DBA" == 'dba' ]]; then
	echo "DBA组已存在"
else
	groupadd dba
fi

#创建oinstall组
GROUP_OINSTALL=`sudo cat /etc/group |grep oinstall |awk -F: '{print $1}'`
if [[ "$GROUP_OINSTALL" == 'oinstall' ]]; then
	echo "oinstall组已存在"
else
	groupadd oinstall
fi

#===============Oracle user===================
#判断oracle用户是否存在
if id oracle &> /dev/null;then
	echo "Oracle用户已存在"
else
	#创建oracle用户
	useradd -g dba -g oinstall oracle -d /home/oracle
echo 'oracle
oracle' | passwd oracle
	echo "oracle用户已创建,密码:oracle"
	id oracle
fi

#2.创建Oracle安装目录
#创建目录
mkdir -p /data
mkdir -p /data/oracle
mkdir -p /data/database
mkdir -p /data/oraInventory

#3.修改系统配置
#为提高yum下载速度,创建本地YUM源
#kill占用mnt目录进程
fuser -km /mnt

#卸载/mnt目录
umount /mnt

#挂镜像到/mnt目录
mount /dev/cdrom /mnt

#删除yum配置文件
rm -rf /etc/yum.repos.d/*
cp -f $SITE/server.repo /etc/yum.repos.d/server.repo

#清理yum残留的数据
yum list all &> /dev/null
yum clean all &> /dev/null

#安装系统需要的包
yum -y install binutils* &> /dev/null
yum -y install compat-libcap1* &> /dev/null
yum -y install gcc* &> /dev/null
yum -y install gcc-c++* &> /dev/null
yum -y install glibc* &> /dev/null
yum -y install glibc-devel* &> /dev/null
yum -y install ksh* &> /dev/null
yum -y install libaio* &> /dev/null
yum -y install libaio-devel* &> /dev/null
yum -y install libgcc* &> /dev/null
yum -y install libstdc++* &> /dev/null
yum -y install libstdc++-devel* &> /dev/null
yum -y install libXi* &> /dev/null
yum -y install libXtst* &> /dev/null
yum -y install make* &> /dev/null
yum -y install sysstat* &> /dev/null

rpm -ivh $SITE/compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm --nodeps &> /dev/null
rpm -ivh $SITE/pdksh-5.2.14-37.el5_8.1.x86_64.rpm --nodeps &> /dev/null

sleep 1

#关闭防火墙
systemctl stop firewalld.service
systemctl disable firewalld.service

#修改系统标识
echo 'redhat-7' > /etc/redhat-release

#关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

#修改内核参数
SYSCTL_PARAMETER=`grep '新添加内容' /etc/sysctl.conf`
if [ $SYSCTL_PARAMETER str ]; then
echo '#==================新添加内容==================
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.rp_filter = 1
fs.file-max = 6815744
#设置最大打开文件数
fs.aio-max-nr = 1048576
kernel.shmall = 2097152
#共享内存的总量，8G内存设置：2097152*4k/1024/1024
kernel.shmmax = 2147483648
#最大共享内存的段大小
kernel.shmmni = 4096
#整个系统共享内存端的最大数
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
#可使用的IPv4端口范围
net.core.rmem_default = 262144
net.core.rmem_max= 4194304
net.core.wmem_default= 262144
net.core.wmem_max= 1048576' >> /etc/sysctl.conf
sysctl -p &> /dev/null
else
	echo "请勿重复运行$0"
fi

#修改最大文件打开数
Open_number=`grep '新添加内容' /etc/security/limits.conf`
if [ $Open_number str ]; then
echo '#==============新添加内容================
oracle soft nproc 20470
oracle hard nproc 163840
oracle soft nofile 10240
oracle hard nofile 655360' >> /etc/security/limits.conf
else
echo "请勿重复运行$0"
fi

#修改Oracle用户环境变量
sleep 1
environment_variable=`grep 'ORACLE_HOME' /home/oracle/.bash_profile`
if [ $environment_variable str ]; then
sudo echo 'export ORACLE_BASE=/data/oracle
#oracle数据库安装目录
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
#oracle数据库路径
export ORACLE_SID=orcl
#oracle启动数据库实例名
export ORACLE_TERM=xterm
#xterm窗口模式安装
export PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH
#添加系统环境变量
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
#添加系统环境变量
export LANG=C
#防止安装过程出现乱码
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
#设置Oracle客户端字符集,必须与Oracle安装时设置的字符集保持一致.
#如:ZHS16GBK，否则出现数据导入导出中文乱码问题' >> /home/oracle/.bash_profile
source /home/oracle/.bash_profile
echo $ORACLE_HOME
else
echo "请勿重复运行$0"
fi

#可能脚本会重复运行,删除原来解压的目录
rm -rf /data/database/database*

sleep 1
#4.解压ORACLE安装包

unzip $SITE/linux.x64_11gR2_database_1of2.zip -d /data/database &> /dev/null
unzip $SITE/linux.x64_11gR2_database_2of2.zip -d /data/database &> /dev/null

#修改database属主,属组
chown -R oracle:oinstall /data/oracle
chown -R oracle:oinstall /data/database*
chown -R oracle:oinstall /data/oraInventory

echo "请手动运行database/下的runInstaller文件"
echo "请手动运行database/下的runInstaller文件"
echo "请手动运行database/下的runInstaller文件"