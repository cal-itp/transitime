#! /bin/sh

CNAME=`gcloud compute ssh $1 --command="docker ps" | grep -v COMMAND | grep -v entrypoint.sh | rev | awk '{print $1}' | rev`
echo CNAME: $CNAME
gcloud compute ssh $1 --container=$CNAME
