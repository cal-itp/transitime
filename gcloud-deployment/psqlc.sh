#! /bin/sh

if [ "$#" -ne 1 ]; then
  echo "Usage: psqlc.sh <agency-id>" >&2
  exit 1
fi

LINE=`head -1 ../docker/core/agency-list.txt | tail -1`
PRIMARY_AGENCY_ID=`echo $LINE | awk '{print $1}'`"-0"
echo "PRIMARY_AGENCY_ID: $PRIMARY_AGENCY_ID"

AGENCY_ID=$1
echo "AGENCY_ID: $AGENCY_ID"
echo

DB_VM="db-$AGENCY_ID"
echo "DB_VM: $DB_VM"
DB_IP=`gcloud compute instances describe $DB_VM --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`
echo "DB_IP: $DB_IP"

psql -h $DB_IP -p 5432 -U postgres -d agency-$AGENCY_ID -c 'select count(*) from trips'
echo

if [ "$AGENCY_ID" == "$PRIMARY_AGENCY_ID" ]; then
    psql -h $DB_IP -p 5432 -U postgres -d agency-$AGENCY_ID -c 'select * from webagencies'
fi
