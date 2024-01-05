#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
python  /xxx/itsm_splunk.python   
或者  chmod +x /xxx/itsm_splunk.python   #给可执行权限
/xxx/itsm_splunk.python

request 和json需要安装
第一种安装方式： #只要能连接yum即可，不需要连接外网
yum install -y python2-requests python2-simplejson

第二种安装方式； #需要能访问yum源，且能访问外网
yum install -y python2-pip
pip install requests json

第三种：
https://pypi.or  下载json 和requests源码包安装

'''
import os
import sys
import csv
import requests
import json
from collections import OrderedDict

csv_zip_file_name = sys.argv[8]
#csv_zip_file_name = "/opt/splunk/var/run/splunk/dispatch/scheduler__admin__test__test_at_1555378800_26/results.csv.gz"

##测试##在/opt/创建filename_0.txt文件,查看第[8]的参数
#f = open("/opt/filename_0.txt","ab+")
#f.write(csv_zip_file_name+'\n')
#f.close()

print(os.path.dirname(csv_zip_file_name))
csv_path = os.path.dirname(csv_zip_file_name)
cmd = "gunzip " + csv_zip_file_name
os.system(cmd)
#csv_name = os.listdir(csv_path)[0]
csv_name = "results.csv"
print(csv_name)
filename = csv_path + "/" + csv_name
print(filename)
report_url = "http://10.138.131.117:8081/app/itsm/api/alertEvent/createSplunkEvent"

with open(filename) as f:
	reader = csv.reader(f)
	print (reader)
	result = list(reader)
	count = 0
	content = OrderedDict();
	for item in   result:   #  0..3
		if count > 0:
			content['title'] = item[0]
			content['ticketDesc'] = item[1]
			content['urgentLevel'] = item[2]
			content['serviceCategory'] = item[3]
			content['ip'] = item[4]
			content['type'] = item[5]
			#title = reader[0]
			#headers = {'Content-Type': 'application/json; charset=utf-8'}
			report_data = json.dumps(content,ensure_ascii=False)
			print (report_data)
			req = requests.post(report_url,data=report_data)
			print(req)
		count = count + 1

'''
1、获取$8  "/home/jijianbo/workspaces/haier/results.csv.gz
2、获取该文件所在的路径 "/home/jijianbo/workspaces/haier/
3、解压
4、拼接csv文件绝对路径
5、读取csv  内容    cat  取第二行 awk  list
6、  curl 
curl -H "Content-Type: application/json" -X POST -d "{\"Sn\":\"$_sn\",\"Title\":\"启动OS安装程序\",\"InstallProgress\":0.6,\"InstallLog\":\"SW5zdGFsbCBPUwo=\"}" http://158.1.0.10:9002/api/osinstall/v1/report/deviceInstallInfo
'''