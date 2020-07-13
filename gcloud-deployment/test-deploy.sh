#! /bin/sh

# take operator count as arg
# stop and delete all existing db, server and core instances

# create primary agency db
# create primary agency core and populate db
# remember agency id and db ip

# for i in count:
#  randomly pick an agency from agency-list.txt
#  create agency id: agency-id-<index>
#  create agency db
#  create agency core

# create server

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 0
fi

if [ "$PGPASSWORD" == "transitclock" ]; then
    echo "PGPASSWORD needs to be set to super-secret external postgres password"
    exit 0
fi

if [ "$#" -ne 1 ]; then
  echo "Usage: test-deploy.sh <core-count>" >&2
  exit 1
fi

CORE_COUNT=$1
echo CORE_COUNT: $CORE_COUNT

INSTANCE_NAMES=""

SAVED_IFS=$IFS
IFS=$'\n'

echo running intances:
for i in `gcloud compute instances list | egrep 'transitclock-|db-' | awk '{print $1}'`
do
    echo "  "$i
    INSTANCE_NAMES=$INSTANCE_NAMES" "$i
done

IFS=$SAVED_IFS

echo INSTANCE_NAMES: $INSTANCE_NAMES

if [ ! -z "$INSTANCE_NAMES" ]; then
    gcloud compute instances delete $INSTANCE_NAMES --delete-disks=all
fi

RMI_HOSTNAME=`gcloud compute instances list | grep rmi-registry | awk '{print $5}'`
echo RMI_HOSTNAME: $RMI_HOSTNAME

AGENCY_COUNT=$((`wc -l ../docker/core/agency-list.txt | awk '{print $1}'` - 1))
echo AGENCY_COUNT: $AGENCY_COUNT

for i in `seq 0 $(($CORE_COUNT - 1))`
do
    MOD_I=$(($i % $AGENCY_COUNT + 1))
    # echo MOD_I: $MOD_I
    LINE=`head -$MOD_I ../docker/core/agency-list.txt | tail -1`
    # echo LINE: $LINE

    AGENCY_ID=`echo $LINE | awk '{print $1}'`"-$i"
    echo "  AGENCY_ID: $AGENCY_ID"
    GTFS_URL=`echo $LINE | awk '{print $2}'`
    echo "  GTFS_URL: $GTFS_URL"
    VEHICLE_POSITIONS_URL=`echo $LINE | awk '{print $3}'`
    echo "  VEHICLE_POSITIONS_URL: $VEHICLE_POSITIONS_URL"

    if [ -z "$PRIMARY_AGENCY_ID" ]; then
        PRIMARY_AGENCY_ID=$AGENCY_ID
    fi
    echo "  PRIMARY_AGENCY_ID: $PRIMARY_AGENCY_ID"

    gcloud compute instances create-with-container db-$AGENCY_ID \
      --container-stdin --container-tty \
      --container-image docker.io/postgres:9.6.3 \
      --boot-disk-size=10GB \
      --tags postgres \
      --container-env POSTGRES_PASSWORD=$PGPASSWORD

    DB_HOSTNAME=`gcloud compute instances list | grep db-$AGENCY_ID | awk '{print $5}'`
    echo "  DB_HOSTNAME: $DB_HOSTNAME"

    if [ -z "$PRIMARY_DB_HOSTNAME" ]; then
        PRIMARY_DB_HOSTNAME=$DB_HOSTNAME
    fi
    echo "  PRIMARY_DB_HOSTNAME: $PRIMARY_DB_HOSTNAME"

    echo "  "

    # $AGENCY_ID $GTFS_URL $VEHICLE_POSITIONS_URL $PRESERVE_DB $RMI_HOSTNAME $DB_HOSTNAME 5432 $PRIMARY_AGENCY_HOST 5432 $PRIMARY_AGENCY_ID
    gcloud compute instances create-with-container transitclock-core-$AGENCY_ID \
      --container-stdin --container-tty \
      --container-image gcr.io/transitclock-282522/core \
      --boot-disk-size=10GB \
      --tags rmi-registry \
      --container-env PGPASSWORD=$PGPASSWORD,AGENCY_ID=$AGENCY_ID,GTFS_URL=$GTFS_URL,VEHICLE_POSITIONS_URL=$VEHICLE_POSITIONS_URL,PRESERVE_DB=0,RMI_HOSTNAME=$RMI_HOSTNAME,DB_HOSTNAME=$DB_HOSTNAME,PRIMARY_AGENCY_HOST=$PRIMARY_DB_HOSTNAME,PRIMARY_AGENCY_ID=$PRIMARY_AGENCY_ID

    sleep 1
done

echo "core started on `date`"
echo "start server manually after 10 mins"


