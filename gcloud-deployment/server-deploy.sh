#! /bin/sh

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 0
fi

if [ "$PGPASSWORD" == "transitclock" ]; then
    echo "PGPASSWORD needs to be set to super-secret external postgres password"
    exit 0
fi

RMI_HOSTNAME=`gcloud compute instances list | grep rmi-registry | awk '{print $5}'`
echo RMI_HOSTNAME: $RMI_HOSTNAME

if [ -z "$RMI_HOSTNAME" ]; then
    echo "rmi registry not running, please start"
    exit 1
fi

LINE=`head -1 ../docker/core/agency-list.txt`

PRIMARY_AGENCY_ID=`echo $LINE | awk '{print $1}'`"-0"
echo "  PRIMARY_AGENCY_ID: $PRIMARY_AGENCY_ID"
GTFS_URL=`echo $LINE | awk '{print $2}'`
echo "  GTFS_URL: $GTFS_URL"
VEHICLE_POSITIONS_URL=`echo $LINE | awk '{print $3}'`
echo "  VEHICLE_POSITIONS_URL: $VEHICLE_POSITIONS_URL"
DB_HOSTNAME=`gcloud compute instances list | grep db-$PRIMARY_AGENCY_ID | awk '{print $5}'`
echo "  DB_HOSTNAME: $DB_HOSTNAME"

if [ -z "$DB_HOSTNAME" ]; then
    echo "primary db not found"
    exit 1
fi

gcloud compute instances create-with-container transitclock-server \
  --container-stdin --container-tty \
  --container-image gcr.io/transitclock-282522/server \
  --boot-disk-size=10GB \
  --tags transitclock-server \
  --container-env PGPASSWORD=$PGPASSWORD,GTFS_URL=$GTFS_URL,VEHICLE_POSITIONS_URL=$VEHICLE_POSITIONS_URL,RMI_HOSTNAME=$RMI_HOSTNAME,DB_HOSTNAME=$DB_HOSTNAME,PRIMARY_AGENCY_ID=$PRIMARY_AGENCY_ID
