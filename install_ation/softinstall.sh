#!/usr/bin/env bash

##                     怎么安装             #####################
##                   下载这个bash文件，执行bash softinstall.sh          ################

##                       安装内容说明                   ####################
##   如果已经安装过某个软件，就会不进行安装这个软件     ####################
##   所有的软件都会安装到   /usr/软件名  对应的目录下   ####################

##          1.安装JDK1.8的版本
##          2.安装git
##          3.安装maven3.6.0版本
##          4.安装mysql8.0版本（注意，这个过程让你选择安装的版本。默认是8.0，还有5.7等版本。这个启动会让你输入root的密码信息）
##          5.安装redis5.0版本（可以选择不安装，将isinstallredis的值改为false）
##          6.安装rocketMQ4.3版本（可以选择不安装，将isinstallrocketmq的值改为false）
##          7.安装nodejs10.13.0版本
##          8.安装Nginx

##                         安装内容结束                 ####################


##                         参数配置                     ##
#定义一些下载地址的变量和保存的位置，下面的参数可以修改的，变量名不要修改。
##      jdk8的参数配置
jdk8down="https://download.oracle.com/otn-pub/java/jdk/8u192-b12/750e1c8617c5452694857ad95c3ee230/jdk-8u192-linux-x64.tar.gz"
jdkpath="java/jdk8"

##      maven3.6的参数配置
maven3_6down="http://mirror.bit.edu.cn/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz"
maven3_6path="maven/maven3.6.0"

##        mysql8.0的deb下载位置
mysql8_0down="https://dev.mysql.com/get/mysql-apt-config_0.8.10-1_all.deb"
mysql8_0path="mysql"

##       redis5.0的参数配置
isinstallredis=true
redis5_0down="http://download.redis.io/releases/redis-5.0.0.tar.gz"
redis5_0path="redis/redis5.0"

##      rocketmq的参数配置
isinstallrocketmq=true
rocketmq4_3down="http://mirror.bit.edu.cn/apache/rocketmq/4.3.0/rocketmq-all-4.3.0-bin-release.zip"
rocketmq4_3path="rocketmq/rocketmq4.3.0"
rocketconf="-server -Xms512m -Xmx1g -Xmn512m"

##      node参数配置
node10_13_0down="https://nodejs.org/dist/v10.13.0/node-v10.13.0-linux-x64.tar.xz"
node10_13_0Path="node/node10.13.0"

##      Nginx的参数配置



####下面的内容不要改变任何内容，上面就是配置参数#############


#版本信息
versionmsg=""
#安装位置
installPath="/usr"
etcprof="/etc/profile"

##                开始安装              ####
#1.更新apt-get
apt-get update

#安装软件

#安装java
versionmsg=`java -version 2>&1`
#如果没有安装java
if [[ ${versionmsg} =~ install.* ]]; then
    ##查看是否有重复目录，如果有的话，就删除
    if [[ -d ${installPath}/${jdkpath} ]]; then
        rm -r -f ${installPath}/${jdkpath}
    fi
    mkdir -p ${installPath}/${jdkpath}
    cd ${installPath}/${jdkpath}/..
    if [[ ! -e ${jdk8down##*/} ]]; then
        wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" ${jdk8down}
    fi
    tar -zxf ${jdk8down##*/} -C ${installPath}/${jdkpath} --strip-component 1
    echo "export JAVA_HOME=${installPath}/${jdkpath}" >> ${etcprof}
    ln -s ${installPath}/${jdkpath}/bin/java /usr/bin/java
    ln -s ${installPath}/${jdkpath}/bin/jar /usr/bin/jar
    ln -s ${installPath}/${jdkpath}/bin/javac /usr/bin/javac
    ##返回源目录
    cd -
fi

#安装git
versionmsg=`git --version 2>&1 `
if [[ ${versionmsg} =~ install.* ]]; then
    apt-get install -y git
fi

#安装maven
versionmsg=`mvn --version 2>&1`
if [[ ${versionmsg} =~ install.* ]]; then
    ##检查目录是否存在，如果存在的话，就删除
    if [[ -d ${installPath}/${maven3_6path} ]]; then
        rm -r -f ${installPath}/${maven3_6path}
    fi
    mkdir -p ${installPath}/${maven3_6path}
    cd ${installPath}/${maven3_6path}/..
    if [[ ! -e ${maven3_6down##*/} ]]; then
        wget ${maven3_6down}
    fi
    tar -zxf ${maven3_6down##*/} -C ${installPath}/${maven3_6path} --strip-component 1
    echo "export MAVEN_HOME=${installPath}/${maven3_6path}" >> ${etcprof}
    ln -s ${installPath}/${maven3_6path}/bin/mvn /usr/bin/mvn
    ln -s ${installPath}/${maven3_6path}/bin/mvnDebug /usr/bin/mvnDebug
    cd -
fi

##安装mysql
versionmsg=`mysql --version 2>&1`
if [[ ${versionmsg} =~ install.* ]]; then
    if [[ ! -e ${installPath}/${mysql8_0path}/${mysql8_0down##*/} ]]; then
        mkdir -p ${installPath}/${mysql8_0path}
        cd ${installPath}/${mysql8_0path}
        wget ${mysql8_0down}
        cd -
    fi
    dpkg -i ${installPath}/${mysql8_0path}/${mysql8_0down##*/}
    apt-get update
    apt-get install -y mysql-server
fi


#安装redis
versionmsg=`redis-server --version 2>&1`
##如果要安装redis，并且没有安装过，就安装，否则就不安装
if [[ ${isinstallredis} == true && ${versionmsg} =~ install.* ]]; then
    apt-get install -y build-essential
    apt-get install -y tcl8.5

    if [[ -d ${installPath}/${redis5_0path} ]]; then
        rm -rf ${installPath}/${redis5_0path}
    fi
    mkdir -p ${installPath}/${redis5_0path}
    cd ${installPath}/${redis5_0path}/..
    if [[ ! -e ${redis5_0down##*/} ]]; then
        wget ${redis5_0down}
    fi
    tar -xzf ${redis5_0down##*/} -C ${installPath}/${redis5_0path} --strip-component 1
    cd ${installPath}/${redis5_0path}
    make
    ln -s ${installPath}/${redis5_0path}/src/redis-server /usr/bin/redis-server
    ln -s ${installPath}/${redis5_0path}/src/redis-cli /usr/bin/redis-cli
    bash ${installPath}/${redis5_0path}/utils/install_server.sh
    cd ~
fi

##rocketmq没有启动
versionmsg=`netstat -nptl | grep '9876'`
if [[ ${isinstallrocketmq} == true && ${versionmsg} == "" ]]; then
    ##如果存在目录，但是不存在指定的启动文件
    if [[ -d ${installPath}/${rocketmq4_3path} && ( ! -e ${installPath}/${rocketmq4_3path}/bin/mqnamesrv ) && ( ! -e ${installPath}/${rocketmq4_3path}/bin/mqbroker ) ]]; then
        rm -rf ${installPath}/${rocketmq4_3path}
    fi
    mkdir -p ${installPath}/${rocketmq4_3path%%/*}
    cd ${installPath}/${rocketmq4_3path%%/*}
    if [[ ! -e ${rocketmq4_3down##*/} ]]; then
        wget ${rocketmq4_3down}
    fi
    apt-get install -y unzip
    unzip ${rocketmq4_3down##*/}
    rocketnametemp=${rocketmq4_3down##*/}
    mv ${rocketnametemp%.*} ${rocketmq4_3path##*/}
read -r SED_EXPR <<-EOF
s#-server\( -Xm[snx][0-9]\+[gm]\)\+#${rocketconf}#;
EOF
    sed "${SED_EXPR}" ${installPath}/${rocketmq4_3path}/bin/runbroker.sh >> ${installPath}/${rocketmq4_3path}/bin/runbroker1.sh
    chmod 755 ${installPath}/${rocketmq4_3path}/bin/runbroker1.sh
    rm -rf ${installPath}/${rocketmq4_3path}/bin/runbroker.sh
    mv ${installPath}/${rocketmq4_3path}/bin/runbroker1.sh ${installPath}/${rocketmq4_3path}/bin/runbroker.sh
    sed "${SED_EXPR}" ${installPath}/${rocketmq4_3path}/bin/runserver.sh >> ${installPath}/${rocketmq4_3path}/bin/runserver1.sh
    chmod 755 ${installPath}/${rocketmq4_3path}/bin/runserver1.sh
    rm -rf ${installPath}/${rocketmq4_3path}/bin/runserver.sh
    mv ${installPath}/${rocketmq4_3path}/bin/runserver1.sh ${installPath}/${rocketmq4_3path}/bin/runserver.sh
fi

##安装node
versionmsg=`node --version 2>&1`
npmversion=`npm --version 2>&1`
if [[ ${versionmsg} =~ install.* || ${npmversion} =~ install.* ]]; then
    if [[ -d ${installPath}/${node10_13_0Path} ]]; then
        rm -r -f ${installPath}/${node10_13_0Path}
    fi
    mkdir -p ${installPath}/${node10_13_0Path}
    cd ${installPath}/${node10_13_0Path}/..
    if [[ ! -e ${node10_13_0down##*/} ]]; then
        wget ${node10_13_0down}
    fi
    tar -xf ${node10_13_0down##*/} -C ${installPath}/${node10_13_0Path} --strip-component 1
    ln -s ${installPath}/${node10_13_0Path}/bin/node /usr/bin/node
    ln -s ${installPath}/${node10_13_0Path}/bin/npm /usr/bin/npm
    cd -
fi
source ${etcprof}

##安装Nginx
versionmsg=`nginx -V`
if [[ ${versionmsg} =~ install.* ]]; then
    apt-get install nginx
fi