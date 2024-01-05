#!/bin/bash
#获取RabbitMQ node数据,格式为json格式.
USER="admin"
PASSWORD="admin"
HOSTNAME="192.168.1.247"
PORT="15672"

curl -u $USER:$PASSWORD http://$HOSTNAME:$PORT/api/nodes > .nodes
cat .nodes
