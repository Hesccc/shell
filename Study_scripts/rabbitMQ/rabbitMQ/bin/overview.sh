#!/bin/bash
#获取rabbitMQ overview数据以json格式返回
USER="admin"
PASSWORD="admin"
HOSTNAME="192.168.1.247"
PORT="15672"

curl -u $USER:$PASSWORD http://$HOSTNAME:$PORT/api/overview > .overview
cat .overview
