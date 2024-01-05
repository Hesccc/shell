# !/bin/bash
# whoami
# root
# chkconfig: 2345 99 01
# /etc/init.d/orcl
# description: starts the oracle dabase deamons

ORACLE_HOME=/oradata/oracle/112
ORACLE_OWNER=oracle

case "$1" in

start)
　　echo -n "Starting orcl: "
　　su - $ORACLE_OWNER -c "$ORACLE_HOME/bin/dbstart"
　　touch /var/lock/subsys/orcl 
　　;;
stop)
　　echo -n "shutting down orcl: "
　　su - $ORACLE_OWNER -c "$ORACLE_HOME/bin/dbshut"
　　rm -f /var/lock/subsys/orcl
　　echo
　　;;
restart)
　　echo -n "restarting orcl: "
　　$0 stop
　　$0 start
　　;;
*)
　　echo "Usage: `basename $0` start|stop|restart"
esac