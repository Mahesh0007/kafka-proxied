#!/bin/sh
. ./common.sh

DIR=`dirname $0`

if [ $? -eq 1 ]; then
  node_name=$host_name
  read -e -p "Cannot determine node name. Please supply a value to name this node: " -i "$node_name" node_name
fi

if [ ! -d config/$kafka_version ]; then
  echo "No configuration templates found for kafka version $kafka_version, Cannot continue"
  exit 1
fi


function create_zookeeper_config() {
  configure_zookeeper
  sed "s/clientPort=.*/clientPort=$zk_port/g" $zookeeper_config_template_file >$zookeeper_config_file
}

function configure_zookeeper() {
  zk_host='localhost'
  read -e -p "Enter the zookeeper host: " -i "$zk_host" zk_host
  zk_port='2181'
  read -e -p "Enter the zookeeper host port: " -i "$zk_port" zk_port
  zk_host_port=$zk_host:$zk_port
}

function create_broker_config() {
  configure_broker
}

function configure_broker() {

  cat $broker_config_template_file> $broker_config_file
  broker_id=`echo $node_name |grep -o '[0-9:]*'`
  number_regex='^[0-9]+$'
  if ! [[ "$broker_id" =~ $number_regex ]]; then
    read -e -p "Enter an appropriate broker id (must be numeric and unique per server): " -i "1" broker_id
  fi
  sed -i "s/broker.id=.*/broker.id=$broker_id/g" $broker_config_file

  broker_port="9091"
  read -e -p "Enter the broker port: " -i "$broker_port" broker_port
  listeners="PLAINTEXT://:$broker_port"
  read -e -p "Enter the the address the socket server listens on (locally): " -i "$listeners" listeners
  sed -i "s#listeners=.*#listeners=$listeners#g" $broker_config_file

  advertised_listeners="PLAINTEXT://public_server:1$broker_port"
  proxy_external="n"
  read -e -p "Will the broker be accessed by a proxy or external public server (y/n)?: " -i "$proxy_external" proxy_external
  if [ "$proxy_external" != "n" ]; then
    read -e -p "Enter Kafka advertised.listeners (all proxies and ips comma separated): " -i "$advertised_listeners" advertised_listeners
    sed -i "s#advertised.listeners=.*#advertised.listeners=$advertised_listeners#g" $broker_config_file
  fi

  configure_zookeeper
  sed -i "s/zookeeper.connect=.*/zookeeper.connect=$zk_host_port/g" $broker_config_file
 
  max_message_size_mb='1'
  read -e -p "Specify maximum message size the broker will accept (message.max.bytes) in MB. Default value (1 MB): " -i $max_message_size_mb max_message_size_mb
  max_message_size=$((1024*1024*$max_message_size_mb))
  sed -i "s#message.max.bytes=.*#message.max.bytes=$max_message_size#g" $broker_config_file

  read -e -p "You must make sure that the Kafka consumer configuration parameter fetch.message.max.bytes is specified as at least $max_message_size!" -i "" bla

  log_segment_size_gb='1'
  read -e -p "Specify Size of a Kafka data file (log.segment.bytes) in GiB. Must be larger than any single message. Default value: (1 GiB): " -i $log_segment_size_gb log_segment_size_gb
  log_segment_size=$((1024*1024*1024*$log_segment_size_gb))
  sed -i "s#log.segment.bytes=.*#log.segment.bytes=$log_segment_size#g" $broker_config_file

  read -e -p "Enter Kafka Log default Retention Hours: " -i "1" kafka_log_retention_hrs
  read -e -p "Enter Kafka Log default Retention Size (Mb): " -i "25" kafka_log_retention_size_mb
  kafka_log_retention_size=$((1024*1024*$kafka_log_retention_size_mb))
  sed -i "s/log.retention.hours=.*/log.retention.hours=$kafka_log_retention_hrs/g" $broker_config_file
  sed -i "s/log.retention.bytes=.*/log.retention.bytes=$kafka_log_retention_size/g" $broker_config_file
                 s
}

function create_mirror_maker_config() {
  cp -vf config/$kafka_version/mm_producer-template.properties $mm_producer_config_file
  cp -vf config/$kafka_version/mm_consumer-template.properties $mm_consumer_config_file
  configure_mirror_maker
}

function configure_mirror_maker() {

  configure_zookeeper
  mirror_maker_zookeeper_connect=$zk_host_port
  read -e -p "Enter Kafka zookeeper_connect for kafka_mirror_maker (consumers): " -i "$mirror_maker_zookeeper_connect" mirror_maker_zookeeper_connect
  sed -i "s/zookeeper.connect=.*/zookeeper.connect=$mirror_maker_zookeeper_connect/g" $mm_consumer_config_file
  sed -i "s/group.id=.*/group.id=$host_name-mirrormaker-group-1/g" $mm_consumer_config_file
  sudo cp -vf $mm_consumer_config_file $KAFKA_HOME/default/config/

  # mirror_maker_bootstrap_servers=`echo $advertised_listeners |sed 's#PLAINTEXT://##g'`
  mirror_maker_bootstrap_server="localhost:9091"
  read -e -p "Enter Kafka bootstrap server for kafka_mirror_maker (producer): " -i "$mirror_maker_bootstrap_server" mirror_maker_bootstrap_server
  sed -i "s/bootstrap.servers=.*/bootstrap.servers=$mirror_maker_bootstrap_server/g" $mm_producer_config_file
  sudo cp -vf $mm_producer_config_file $KAFKA_HOME/default/config/

}

function cleanup_kafka() {

  if [ ! -d $kafka_runtime_console_logs_dir ]; then\
    mkdir -p $kafka_runtime_console_logs_dir \
    && chmod 1777 $kafka_runtime_console_logs_dir
  else
    read -e -p "Destroy old console logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      rm -frv $kafka_runtime_console_logs_dir/*
    fi
  fi

  if [ ! -d $kafka_runtime_config_dir ]; then
    mkdir -p $kafka_runtime_config_dir \
    && chmod 1777 $kafka_runtime_config_dir
  else
    read -e -p "Destroy old kafka configuration files? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      rm -frv $kafka_runtime_config_dir/*
    fi
  fi

  if [ -d /tmp/kafka-logs ]; then
    read -e -p "Destroy old persistent Kafka Broker logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      rm -frv /tmp/kafka-logs
    fi
  fi

  if [ -d /tmp/zookeeper ]; then
    read -e -p "Destroy old persistent Kafka Zookeeper logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      rm -frv /tmp/zookeeper
    fi
  fi

}
