> Thanks https://github.com/Yolean/kubernetes-kafka.


```sh

# Pre-req 
oc cluster up  # setup openshift on docker for Mac  (Skip this if you already have a cluster)
git clone https://github.com/debianmaster/openshift-kafka.git && cd openshift-kafka
oc login -u system:admin



# Create namespace
oc new-project kafka

# Unfortunately we need root priv for the containers that are used in this example
oc adm policy add-scc-to-user anyuid -z default

# Create Persistant Volumes  No londer need these
#./zookeeper/bootstrap/pv.sh
#./bootstrap/pv.sh

# Create  Persistant volumes claims
oc create -f ./bootstrap/pvc.yml
oc create -f ./zookeeper/bootstrap/pvc.yml

# Create Zookeeper & Kakfa
oc create -f ./zookeeper/service.yml
oc create -f ./zookeeper/zookeeper.yaml 
oc create -f ./

# Test
oc create -f test/99testclient.yml
oc rsh testclient   #terminal 1
oc rsh testclient   #terminal 2

## Inside testclient container Terminal 1
./bin/kafka-topics.sh --zookeeper zookeeper:2181 --topic test1 --create --partitions 1 \
--replication-factor 1 #create topic
./bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --topic test1 \
--from-beginning #read topic

## Inside testclient container Terminal 2
./bin/kafka-console-producer.sh --broker-list kafka-0.broker.kafka.svc.cluster.local:9092,\
kafka-1.broker.kafka.svc.cluster.local:9092 --topic test1    # Type message and press ^Z when done, check terminal 1


# Scale up Cluster
oc edit petset kakfa  #change replicas to desired number (make sure you have enough PV,PVC)

# Cleanup
oc delete all,petset --all
oc delete pv,pvc --all
```

![Demo Image](https://pbs.twimg.com/media/Cx5nXXQVIAEOvzL.jpg:large)
