#!/bin/bash
# A Munro 24 Aug 2017: Startup openshift origin, create the project, and then load up the metadata.

project=kafka

oc cluster up && {
  oc login -u system:admin
  oc policy add-role-to-user admin developer # So we can access all projects on the gui
  oc new-project $project

# Allow pods to run as root; by default in openshift its an unpriv user with a high uid. 
# As a docker default most containers runs as root, and this is insecure. The developers have decided this is not good default behaviour.
# But if you use a docker image from say docker hub, it expects to run as root, and most images would fail to run.
# Thus you would probably need to develop your own docker images that allow this. So this is a to do.

  oc adm policy add-scc-to-user anyuid -n $project -z default --config=/var/lib/origin/openshift.local.config/master/admin.kubeconfig

  # Create  Persistant volumes claims
  oc create -f ./bootstrap/pvc.yml
  oc create -f ./zookeeper/bootstrap/pvc.yml

  # Create Zookeeper
  oc create -f ./zookeeper/service.yml
  oc create -f ./zookeeper/zookeeper.yaml 

  # kafka is dependant on zookeeper, so lets wait for it to startup. If we don't do this, the kafka pods go through lots of restarts.
  # k8s does not have any dependancy features between say services, although there are ways to do it.
  echo Waiting for zookeeper to startup...
  c=0
  while [ -z "$(oc get statefulset zoo|awk '!/^NAME/ {if ($2 == $3) {print "Started"}}')" ]
  do
    oc get statefulsets
    sleep 30 
    ((c++))
    [ $c -eq 10 ] && {
      echo Pod creation went wrong. Investigate.
      oc get pods
      exit 1
    }
  done

# And an additional sleep
  sleep 15 

  # Create Kafka; hopefully no restarts as zookeeper statefulset is up fully.
  oc create -f ./

  # Test client
  oc create -f test/99testclient.yml
}
