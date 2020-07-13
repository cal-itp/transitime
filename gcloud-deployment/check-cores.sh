#! /bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: check-cores.sh <core-count>" >&2
  exit 1
fi

CORE_COUNT=$1

AGENCY_COUNT=$((`wc -l ../docker/core/agency-list.txt | awk '{print $1}'` - 1))
echo AGENCY_COUNT: $AGENCY_COUNT

for i in `seq 0 $(($CORE_COUNT - 1))`
do
    MOD_I=$(($i % $AGENCY_COUNT + 1))
    LINE=`head -$MOD_I ../docker/core/agency-list.txt | tail -1`
    AGENCY_ID=`echo $LINE | awk '{print $1}'`"-$i"
    DB_VM="db-$AGENCY_ID"
    echo "  DB_VM: $DB_VM"
    DB_IP=`gcloud compute instances describe $DB_VM --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`
    echo "  DB_IP: $DB_IP"
    echo "  "
done