#!/bin/bash
# 可修改变量
LOG_PATH=/opt/logs     #日志路径
R_TIME=6                #过期时间

##### 以下内容不要修改

SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd)
FILE_NAME=`/bin/date +"%Y-%m-%d"`
find $LOG_PATH -name '*.log' -mtime +${R_TIME} -type f >> $SCRIPT_PATH/${FILE_NAME}.log           # 脚本运行记录，记录每次删除的日志清单
find $LOG_PATH -name '*.log' -mtime +${R_TIME} -type f -exec rm {} \;                             # 执行删除操作