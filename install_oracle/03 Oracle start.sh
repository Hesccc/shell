#!/bin/bash
#
#本脚本设置oracle开机启动

#设置ORACLE_HOME环境
ORACLE_HOME='/data/oracle/product/11.2.0/dbhome_1'

#编辑oratab文件
#将orcl:/oracle_database/oracle/product/11.2.0/dbhome_1:N改成Y
sed -i 's/N/Y/g' $ORACLE_HOME/install/oratab

#将dbstart文件内容
#$1改成$ORACLE_HOME
sed -i 's/ORACLE_HOME_LISTNER=$1/ORACLE_HOME_LISTNER=$ORACLE_HOME/g' $ORACLE_HOME/bin/dbstart
#将dbstart文件内容
#ORATAB=/etc/oratab改成 /data/oracle/product/11.2.0/dbhome_1/install/oratab
sed -i 's/ORATAB=/etc/oratab/ORATAB=/data/oracle/product/11.2.0/dbhome_1/install/oratab/g' $ORACLE_HOME/bin/dbstart

#设置开机自启配置
echo 'su oracle -lc "/data/oracle/product/11.2.0/dbhome_1/bin/lsnrctl start"' >> /etc/rc.local
echo 'su oracle -lc "/data/oracle/product/11.2.0/dbhome_1/bin/dbstart"' >> /etc/rc.local

#给/etc/rc.local文件添加执行权限
chmod +x /etc/rc.local
chmod 755 $ORACLE_HOME/listener.log

echo '#!/bin/bash
# chkconfig: 345 61 61
# description: Oracle 11g R2 AutoRun Servimces
# /etc/init.d/oracle
#
# Run-level Startup script for the Oracle Instance, Listener, and
# Web Interface
export ORACLE_BASE=/data/oracle
export ORACLE_HOME=$ORACLE_BASE/oracle/product/11.2.0/dbhome_1
export ORACLE_SID=ORCL
export PATH=$PATH:$ORACLE_HOME/bin
ORA_OWNR="oracle"
# if the executables do not exist -- display error
if [ ! -f $ORACLE_HOME/bin/dbstart -o ! -d $ORACLE_HOME ]
then
echo "Oracle startup: cannot start"
exit 1
fi
# depending on parameter -- startup, shutdown, restart
# of the instance and listener or usage display
case "$1" in
start)
# Oracle listener and instance startup
su $ORA_OWNR -lc $ORACLE_HOME/bin/dbstart
echo "Oracle Start Succesful!OK."
;;
stop)
# Oracle listener and instance shutdown
su $ORA_OWNR -lc $ORACLE_HOME/bin/dbshut
echo "Oracle Stop Succesful!OK."
;;
reload|restart)
$0 stop
$0 start
;;
*)
echo $"Usage: `basename $0` {start|stop|reload|reload}"
exit 1
esac
exit 0 ' >> /etc/init.d/oracle

chmod +x /etc/init.d/oracle