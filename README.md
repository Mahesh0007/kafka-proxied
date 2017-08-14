# kafka-proxied
## Exposing Kafka Cluster through Public Network Gateway


![kafka_cluster_topology](kafka_cluster_topology.PNG)


### Internal Network Kafka Cluster Configuration

#### kafka_node_1 (runs Kafka-Zookeeper and Kafka-Broker-1 processes)
This node in the cluster will run a Zookeper instance and a Broker instance. 
This shows the configurations for each process

##### kafka-zookeeper-1-config.properties (no special requirements)
```
dataDir=/tmp/zookeeper
clientPort=2181
maxClientCnxns=0
```

##### kafka-broker-1-config.properties (required to expose public cluster details)
```
broker.id=1
listeners=PLAINTEXT://:9091
advertised.listeners=PLAINTEXT://cleverfishsoftware.com:9091
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
message.max.bytes=1048576
log.segment.bytes=1073741824
log.dirs=/tmp/kafka-logs/1
num.partitions=1
num.recovery.threads.per.data.dir=1
log.retention.hours=1
log.retention.bytes=26214400
log.retention.check.interval.ms=300000
zookeeper.connect=cleverfishsoftware.com:2181
zookeeper.connection.timeout.ms=16000
```

##### /etc/hosts (required dns resolution to the public cluster nodes)

```
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.81 engine1 engine1.cleverfishsoftware.com cleverfishsoftware.com
192.168.1.82 engine2 engine2.cleverfishsoftware.com
192.168.1.83 engine3 engine3.cleverfishsoftware.com
192.168.1.85 Peters-iMac iMac Peters-iMac.hsd1.co.comcast.net
192.168.1.88 Peters-MBP MBP Peters-MBP.hsd1.co.comcast.net
```

##### firewall config (inbound rules need to allow for external/internal connections)

```
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eno1
  sources: 
  services: dhcpv6-client nfs ssh
  ports: 2222/tcp 5800/tcp 9889/tcp 9393/tcp 38080/tcp 8443/tcp 8000/tcp 5080/tcp 3389/tcp
  protocols: 
  masquerade: no
  forward-ports: 
  sourceports: 
  icmp-blocks: 
  rich rules: 
	rule family="ipv4" source address="192.168.1.82" port port="5001" protocol="udp" accept
	rule family="ipv4" source address="192.168.1.82" port port="5001" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.81" port port="19091-19093" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.81" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.81" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.82" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.82" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.83" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.83" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="40.112.255.211" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="40.112.255.211" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="40.78.64.141" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="40.78.64.141" port port="2181" protocol="tcp" accept
```

- - -

#### kafka_node_2 (runs Kafka-Broker-2 process)
##### kafka-broker-1-config.properties (required to expose public cluster details)

```
broker.id=2
listeners=PLAINTEXT://:9092
advertised.listeners=PLAINTEXT://cleverfishsoftware.com:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
message.max.bytes=1048576
log.segment.bytes=1073741824
log.dirs=/tmp/kafka-logs/2
num.partitions=1
num.recovery.threads.per.data.dir=1
log.retention.hours=1
log.retention.bytes=26214400
log.retention.check.interval.ms=300000
zookeeper.connect=cleverfishsoftware.com:2181
zookeeper.connection.timeout.ms=16000

```

##### /etc/hosts (required dns resolution to the public cluster nodes)

```
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.81 engine1 engine1.cleverfishsoftware.com 
192.168.1.82 engine2 engine2.cleverfishsoftware.com cleverfishsoftware.com
192.168.1.83 engine3 engine3.cleverfishsoftware.com
```

##### firewall config (inbound rules need to allow for external/internal connections)
```
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eno1
  sources: 
  services: dhcpv6-client ssh
  ports: 9000/tcp
  protocols: 
  masquerade: no
  forward-ports: 
  sourceports: 
  icmp-blocks: 
  rich rules: 
	rule family="ipv4" source address="192.168.1.81" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="40.112.255.211" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="40.78.64.141" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.82" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.83" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.85" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.85" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.141" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.141" port port="9091-9093" protocol="tcp" accept

```

- - -

#### kafka_node_3 (runs Kafka-Broker-3 process)
- - -
##### kafka-broker-1-config.properties (required to expose public cluster details)

```
broker.id=3
listeners=PLAINTEXT://:9093
advertised.listeners=PLAINTEXT://cleverfishsoftware.com:9093
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
message.max.bytes=1048576
log.segment.bytes=1073741824
log.dirs=/tmp/kafka-logs/3
num.partitions=1
num.recovery.threads.per.data.dir=1
log.retention.hours=1
log.retention.bytes=26214400
log.retention.check.interval.ms=300000
zookeeper.connect=cleverfishsoftware.com:2181
zookeeper.connection.timeout.ms=16000
```

- - -
##### /etc/hosts (required dns resolution to the public cluster nodes)

```
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.81 engine1 engine1.cleverfishsoftware.com 
192.168.1.82 engine2 engine2.cleverfishsoftware.com
192.168.1.83 engine3 engine3.cleverfishsoftware.com cleverfishsoftware.com
```

##### firewall config (inbound rules need to allow for external/internal connections)

```
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlo1
  sources: 
  services: dhcpv6-client ssh
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  sourceports: 
  icmp-blocks: 
  rich rules: 
	rule family="ipv4" source address="40.112.255.211" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="40.112.255.211" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="40.78.64.141" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="40.78.64.141" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.81" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.81" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.82" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.82" port port="9091-9093" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.83" port port="2181" protocol="tcp" accept
	rule family="ipv4" source address="192.168.1.83" port port="9091-9093" protocol="tcp" accept
```

- - -
#### Peters-iMac
- ip must be allow to connect on each node

### External Network Kafka Clients (consumer and producer)

#### hospitalityhertzpocnode1 (run the kafka console producer)
```bash
[petergdoyle@hospitalityhertzpocnode1 scripts]$ ./start_kafka_console_producer.sh 
Enter a kafka broker server: cleverfishsoftware.com:9091
Enter the topic name: kafka-simple-topic-1
/usr/kafka/default/bin/kafka-console-producer.sh --broker-list cleverfishsoftware.com:9091 --topic kafka-simple-topic-1
message10
message11
message12
```

- - -
#### hospitalityhertzpocnode0 (run the kafka console consumer)
```bash
[petergdoyle@hospitalityhertzpocnode0 ~]$ /usr/kafka/default/bin/kafka-console-consumer.sh --new-consumer --bootstrap-server cleverfishsoftware.com:9091 --topic kafka-simple-topic-1 --from-beginning
[2017-08-14 15:28:30,260] INFO ConsumerConfig values: 
	auto.commit.interval.ms = 5000
	auto.offset.reset = earliest
	bootstrap.servers = [cleverfishsoftware.com:9091]
	check.crcs = true
	client.id = 
	connections.max.idle.ms = 540000
	enable.auto.commit = true
	exclude.internal.topics = true
	fetch.max.bytes = 52428800
	fetch.max.wait.ms = 500
	fetch.min.bytes = 1
	group.id = console-consumer-63744
	heartbeat.interval.ms = 3000
	interceptor.classes = null
	key.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
	max.partition.fetch.bytes = 1048576
	max.poll.interval.ms = 300000
	max.poll.records = 500
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.sample.window.ms = 30000
	partition.assignment.strategy = [class org.apache.kafka.clients.consumer.RangeAssignor]
	receive.buffer.bytes = 65536
	reconnect.backoff.ms = 50
	request.timeout.ms = 305000
	retry.backoff.ms = 100
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	send.buffer.bytes = 131072
	session.timeout.ms = 10000
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2, TLSv1.1, TLSv1]
	ssl.endpoint.identification.algorithm = null
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLS
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
	value.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
 (org.apache.kafka.clients.consumer.ConsumerConfig)
[2017-08-14 15:28:30,265] INFO ConsumerConfig values: 
	auto.commit.interval.ms = 5000
	auto.offset.reset = earliest
	bootstrap.servers = [cleverfishsoftware.com:9091]
	check.crcs = true
	client.id = consumer-1
	connections.max.idle.ms = 540000
	enable.auto.commit = true
	exclude.internal.topics = true
	fetch.max.bytes = 52428800
	fetch.max.wait.ms = 500
	fetch.min.bytes = 1
	group.id = console-consumer-63744
	heartbeat.interval.ms = 3000
	interceptor.classes = null
	key.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
	max.partition.fetch.bytes = 1048576
	max.poll.interval.ms = 300000
	max.poll.records = 500
	metadata.max.age.ms = 300000
	metric.reporters = []
	metrics.num.samples = 2
	metrics.sample.window.ms = 30000
	partition.assignment.strategy = [class org.apache.kafka.clients.consumer.RangeAssignor]
	receive.buffer.bytes = 65536
	reconnect.backoff.ms = 50
	request.timeout.ms = 305000
	retry.backoff.ms = 100
	sasl.kerberos.kinit.cmd = /usr/bin/kinit
	sasl.kerberos.min.time.before.relogin = 60000
	sasl.kerberos.service.name = null
	sasl.kerberos.ticket.renew.jitter = 0.05
	sasl.kerberos.ticket.renew.window.factor = 0.8
	sasl.mechanism = GSSAPI
	security.protocol = PLAINTEXT
	send.buffer.bytes = 131072
	session.timeout.ms = 10000
	ssl.cipher.suites = null
	ssl.enabled.protocols = [TLSv1.2, TLSv1.1, TLSv1]
	ssl.endpoint.identification.algorithm = null
	ssl.key.password = null
	ssl.keymanager.algorithm = SunX509
	ssl.keystore.location = null
	ssl.keystore.password = null
	ssl.keystore.type = JKS
	ssl.protocol = TLS
	ssl.provider = null
	ssl.secure.random.implementation = null
	ssl.trustmanager.algorithm = PKIX
	ssl.truststore.location = null
	ssl.truststore.password = null
	ssl.truststore.type = JKS
	value.deserializer = class org.apache.kafka.common.serialization.ByteArrayDeserializer
 (org.apache.kafka.clients.consumer.ConsumerConfig)
[2017-08-14 15:28:30,476] INFO Kafka version : 0.10.1.1 (org.apache.kafka.common.utils.AppInfoParser)
[2017-08-14 15:28:30,476] INFO Kafka commitId : f10ef2720b03b247 (org.apache.kafka.common.utils.AppInfoParser)
[2017-08-14 15:28:30,661] INFO Discovered coordinator cleverfishsoftware.com:9091 (id: 2147483646 rack: null) for group console-consumer-63744. (org.apache.kafka.clients.consumer.internals.AbstractCoordinator)
[2017-08-14 15:28:30,662] INFO Revoking previously assigned partitions [] for group console-consumer-63744 (org.apache.kafka.clients.consumer.internals.ConsumerCoordinator)
[2017-08-14 15:28:30,662] INFO (Re-)joining group console-consumer-63744 (org.apache.kafka.clients.consumer.internals.AbstractCoordinator)
[2017-08-14 15:28:30,786] INFO Successfully joined group console-consumer-63744 with generation 1 (org.apache.kafka.clients.consumer.internals.AbstractCoordinator)
[2017-08-14 15:28:30,786] INFO Setting newly assigned partitions [kafka-simple-topic-1-0] for group console-consumer-63744 (org.apache.kafka.clients.consumer.internals.ConsumerCoordinator)
message10
message11
message12

```

- - -


## Notes:

- a proxy may be required if the port on the host machine (engine1, 2, 3) cannot be mapped directly to the same port 

