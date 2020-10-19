#! /bin/sh

CLUSTER_IP=`gcloud compute instances list | grep 'transitclock-cluster-1' | awk '{print $5}'`

if [ -z "$CLUSTER_IP" ]
then
  echo error: cluster-1 not running, fatal
fi

echo CLUSTER_IP: $CLUSTER_IP

java -cp ~/projects/tc-core-admin/classes Client -host $CLUSTER_IP -port 6789 -key-file ~/projects/lat-long-prototype/keys/core-admin/id_rsa
echo cluster config complete
