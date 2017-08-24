> Thanks https://github.com/Yolean/kubernetes-kafka.

# Introduction

Its assumed you have installed Openshift Origin (tested with v3.6.0), docker (v1.13.0; not CE/EE versions), etc. 

This script automates the setup. Take a look at the script before you run it:

```sh

./openshift-startup.sh
```

# Testing

Create two sessions to the test client so we can send and see messages received:

```
$ oc rsh testclient bash   # terminal 1
$ oc rsh testclient bash   # terminal 2
```

Inside testclient pod Terminal 1:
```
# ./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic test1 --create --partitions 1 \
--replication-factor 1 #create topic
# ./bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --topic test1 \
--from-beginning #read topic from the beginning
```

Inside testclient pod Terminal 2:
```
# ./bin/kafka-console-producer.sh --broker-list kafka-0.broker.kafka.svc.cluster.local:9092,\
kafka-1.broker.kafka.svc.cluster.local:9092 --topic test1    # Type in messages and see if they arrive on Terminal 1. Press ^Z to exit.

```

# Scale up Cluster

I would suggest you update the metadata config in the .yml files. Thus shutdown Openshift and then re-run openshift-startup.sh. You will need to add additional PV claims. 

For zookeeper they recommend you have 3 replicas as a minimum setup (default) and 5 for a prod setup. Ideally it should be an odd number.

For kafka you might want to do some research on the optimal; the default is 3 replicas (or brokers).


# Cleanup

Openshift Origin does not maintain any state, so just shut it down to clear down the config:


```
oc cluster down
```

# Accessing the project via the Openshift web gui

I have added admin access to the developer user, so it can see all projects. The startup script would have advised on the gui url; something like this. Thus login as developer at the url:

```
The server is accessible via web console at:
    https://127.0.0.1:8443

You are logged in as:
    User:     developer
    Password: <any value>
```

![Demo Image](https://pbs.twimg.com/media/Cx5nXXQVIAEOvzL.jpg:large)
