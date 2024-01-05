#!/bin/bash
# 
# Creation time : 2021/12/02 18:38:07
# Version : 1.6
# Founder : Hesc

# Elasticsearch install parameter
#----------------------------------- cluster -----------------------------------
export cluster_name='testES'                             # 集群名称
# ------------------------------------ Node ------------------------------------
export node_name='hn01'                                  #本节点名称
export node_master='true'                                #是否为主节点
export node_data='true'                                  #本节点是否存放数据
export discovery_zen_ping_unicast_hosts='10.10.0.20'     #主节点ip地址
export path_data='/opt/elasticsearch-2.3.0/data'         #文件存放路径
export path_logs='/opt/elasticsearch-2.3.0/logs'         # 日志存放路径


#----------------------------------- 分隔线 ------------------------------------
export network_host=`ip addr | grep 'inet '|grep -v '127.0.0.1' | head -n 1| awk '{ print $2}'| awk -F "/" '{ print $1 }'`
#本节点ip地址
export openFile=`ulimit -a|grep "open files" | awk '{ print $4 }'`
echo -e "\033[32m========================= Start Install Elasticsearch ==========================\033[0m"
echo -e "\033[32m========================= In 2 Seconds starts install ==========================\033[0m"

sleep 2

echo -e "\033[32m============================ Download resource Packs ===========================\033[0m"
# curl http://hescinfo-images.oss-cn-shenzhen.aliyuncs.com/soft/jdk-7u67-linux-x64.rpm -o /opt/jdk-7u67-linux-x64.rpm    # 下载Oracle jdk安装包
# curl http://hescinfo-images.oss-cn-shenzhen.aliyuncs.com/soft/elasticsearch-2.3.0.tar.gz -o /opt/elasticsearch-2.3.0.tar.gz  # 下载elasticsearch-2.3.0 安装包

echo -e "\033[32m========================= Modifying System Configurations ======================\033[0m"
echo -e "\033[32m============================ In 5 Seconds start runing =========================\033[0m"
sleep 5
if [ -f /opt/elasticsearch-2.3.0.tar.gz ]; then
    if [ -f /opt/jdk-7u67-linux-x64.rpm ]; then
        
        # 关闭CentOS防火墙
        if [ -f /usr/lib/systemd/system/firewalld.service ]; then
            echo -e "\033[32mINFO: CentOS 7 Disable the firewall.\033[0m"
            systemctl stop firewalld.service
            systemctl disable firewalld.service
        else 
            echo -e "\033[32mINFO: CentOS 6 Disable the firewall.\033[0m"
            service iptables stop
            chkconfig iptables off
        fi
        
        # 修改系统ulimit配置
        if [ $openFile -gt 6400 ];then
            echo -e "\033[31mERROR: If the default value is greater than 640000, skip the modification!\033[0m"
        else
            echo -e "\033[32mINFO: alter system ulimit configuration!\033[0m"
            ulimit -n 640000
            ulimit -d unlimited
            ulimit -f unlimited 
            ulimit -u unlimited 
            ulimit -a
            echo "*  soft  nofile  640000"    >> /etc/security/limits.conf
            echo "*  hard  nofile  640000"    >> /etc/security/limits.conf
            echo "*  soft  nproc 	640000"   >> /etc/security/limits.conf
            echo "*  hard  nproc 	640000"   >> /etc/security/limits.conf
            echo "*  soft  memlock unlimited" >> /etc/security/limits.conf
            echo "*  hard  memlock unlimited" >> /etc/security/limits.conf
        fi
        
        # 创建es用户
        sleep 2
        if id es &>> /dev/null; then
            echo -e "\033[31mERROR: ES User already exists. Do not run repeatedly!\033[0m"
        else
            echo es|passwd --stdin es &> /dev/null
            useradd -m es
            echo -e "\033[32mINFO: The es user has been created and its password is \"es\".\033[0m"
        fi
        
        # 开始安装Oracle JDK
        sleep 2
        if [ $JAVA_HOME ]; then
            echo -e "\033[31mERROR: Oracle JDK already install! $JAVA_HOME\033[0m"
        else 
            rpm -ivh /opt/jdk-7u67-linux-x64.rpm
            echo "export PATH=/usr/java/jdk1.7.0_67/bin:\$PATH" >> /etc/profile
            echo "export JAVA_HOME=/usr/java/1.7.0_67" >> /etc/profile
            echo "export JAVA_BIN=/usr/java/jdk1.7.0_67/bin" >> /etc/profile
            echo "export JAVA_PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
            echo "export JAVA_CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
            echo "export JAVA_HOME JAVA_BIN JAVA_PATH JAVA_CLASSPATH PATH" >> /etc/profile
            source /etc/profile
            java -version
            echo -e "\033[32mOracle JDK Install Path:/usr/java/jdk1.7.0_67\033[0m"
        fi
    else
        echo -e "\033[31m ERROR: The /opt/jdk-7u67-linux-x64.rpm is no!\033[0m"
        exit 8
    fi

    # 开始配置elasticsearch
    sleep 2
    tar -zxf /opt/elasticsearch-2.3.0.tar.gz -C /opt/
echo "# ======================== Elasticsearch Configuration =========================
# Use a descriptive name for your cluster:
#集群名称
cluster.name: $cluster_name
# ------------------------------------ Node ------------------------------------
# Use a descriptive name for the node:
#本节点名称
node.name: $node_name
#是否为主节点
node.master: $node_master
#主节点ip地址
discovery.zen.ping.unicast.hosts: [\"$discovery_zen_ping_unicast_hosts\"]
#本节点ip地址
network.host: $network_host
#本节点是否存放数据
node.data: $node_data
#文件存放路径
path.data: $path_data
# 日志存放路径
path.logs: $path_logs
# Add custom attributes to the node:
# node.rack: r1
# ----------------------------------- Paths ------------------------------------
# Path to directory where to store the data (separate multiple locations by comma):
# node.master: false
# Path to log files:
# ----------------------------------- Memory -----------------------------------
# Lock the memory on startup:
# bootstrap.mlockall: true
# Make sure that the \`ES_HEAP_SIZE\` environment variable is set to about half the memory
# available on the system and that the owner of the process is allowed to use this limit.
# Elasticsearch performs poorly when the system is swapping the memory.
# ---------------------------------- Network -----------------------------------
# Set the bind address to a specific IP (IPv4 or IPv6):
# Set a custom port for HTTP:
# http.port: 9200
# For more information, see the documentation at:
# <http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-network.html>
# --------------------------------- Discovery ----------------------------------
# Pass an initial list of hosts to perform discovery when new node is started:
# The default list of hosts is [127.0.0.1, [::1]]
# Prevent the \"split brain\" by configuring the majority of nodes (total number of nodes / 2 + 1):
# discovery.zen.minimum_master_nodes: 3
# For more information, see the documentation at:
# <http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery.html>
# ---------------------------------- Gateway -----------------------------------
# Block initial recovery after a full cluster restart until N nodes are started:
# gateway.recover_after_nodes: 3
# For more information, see the documentation at:
# <http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-gateway.html>
# ---------------------------------- Various -----------------------------------
# Disable starting multiple nodes on a single system:
# node.max_local_storage_nodes: 1
# Require explicit names when deleting indices:
# action.destructive_requires_name: true
index.number_of_replicas: 0
bootstrap.mlockall: true
index.cache.field.type: soft
index.refresh_interval: 60s
index.merge.policy.merge_factor: 100
index.merge.policy.min_merge_docs: 2000
index.merge.policy.use_compound_file: false
index.translog.flush_threshold: 10000
indices.fielddata.cache.size: 30%
indices.fielddata.cache.expire: 5m
indices.recovery.max_size_per_sec: 100mb
indices.memory.index_buffer_size: 20%
indices.memory.min_shard_index_buffer_size: 16mb
indices.recovery.concurrent_streams: 5
cluster.routing.allocation.cluster_concurrent_rebalance: 4
cluster.routing.allocation.node_concurrent_recoveries: 4
cluster.routing.allocation.disable_allocation: false
threadpool.bulk.queue_size: 2000
index:
  analysis:
    analyzer:
      ik:
          type: ik
          use_smart: true
      ik_smart:
          type: ik
          use_smart: true
      ik_max_word:
          type: ik
          use_smart: false
      pinyin_analyzer_term:
          type: custom
          tokenizer: my_pinyin
          filter:
          - standard
          - lowercase
          - trim
      pinyin_first_letter_analyzer:
          type: custom
          tokenizer: pinyin_first_letter
          filter:
          - standard
          - lowercase
      pinyin_analyzer:
          type: custom
          tokenizer: my_pinyin_analyzer
          filter:
          - standard
          - lowercase
          - trim
      pinyin_prefix:
          type: custom
          tokenizer: my_pinyin_prefix
          filter:
          - standard
          - lowercase
          - trim
          - nGram
      single:
          type: custom
          tokenizer: singletoken
          filter:
          - lowercase
          - trim
    tokenizer:
      my_pinyin:
          type: pinyin
          first_letter: none
          padding_char: ''
      my_pinyin_analyzer:
          type: pinyin
          first_letter: none
          padding_char: ' '
      my_pinyin_prefix:
          type: pinyin
          first_letter: prefix
          padding_char: ''
      pinyin_first_letter:
          type: pinyin
          first_letter: only
      singletoken:
          type: standard
          max_token_length: 1" > /opt/elasticsearch-2.3.0/config/elasticsearch.yml
    echo -e "\033[32m===========================================================\033[0m"
    echo -e "\033[32m||  UserName:es                                          ||\033[0m"
    echo -e "\033[32m||  Password:es                                          ||\033[0m"
    echo -e "\033[32m||  Elasticsearch Install Path:/opt/elasticsearch-2.3.0  ||\033[0m"
    echo -e "\033[32m||  INFO: Elasticsearch installation is complete!        ||\033[0m"
    echo -e "\033[32m===========================================================\033[0m"


else
    echo -e "\033[31mERROR: The /opt/elasticsearch-2.3.0.tar.gz is no!\033[0m"
    exit 8
fi