#! /bin/sh

CNAME=`gcloud compute ssh transitclock-core-$1 --command="docker ps" | grep transitclock-282522/core | rev | awk '{print $1}' | rev`
echo CNAME: $CNAME
gcloud compute ssh transitclock-core-$1 --container=$CNAME