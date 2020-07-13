#! /bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: logc.sh <agency-id>" >&2
  exit 1
fi

AGENCY_ID=$1
echo "AGENCY_ID: $AGENCY_ID"
echo

CNAME=`gcloud compute ssh transitclock-core-$AGENCY_ID --command="docker ps" | grep transitclock-282522/core | rev | awk '{print $1}' | rev`
echo CNAME: $CNAME
gcloud compute ssh transitclock-core-$AGENCY_ID --command="docker logs $CNAME"