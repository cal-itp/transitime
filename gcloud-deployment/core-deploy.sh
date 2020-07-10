#! /bin/sh

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 0
fi

if [ "$PGPASSWORD" == "transitclock" ]; then
    echo "PGPASSWORD needs to be set to super-secret external postgres password"
    exit 0
fi

AGENCY_ID="halifax"
GTFS_URL="http://gtfs.halifax.ca/static/google_transit.zip"
VEHICLE_POSITIONS_URL="http://gtfs.halifax.ca/realtime/Vehicle/VehiclePositions.pb"
PRESERVE_DB="1"
RMI_HOSTNAME="34.94.24.132"
DB_HOSTNAME="34.94.231.127"
PRIMARY_AGENCY_HOST="34.94.231.127"
PRIMARY_AGENCY_ID="halifax"

gcloud compute instances create-with-container transitclock-core-$AGENCY_ID \
  --container-stdin --container-tty \
  --container-image gcr.io/transitclock-282522/core \
  --boot-disk-size=10GB \
  --tags rmi-registry \
  --container-env PGPASSWORD=$PGPASSWORD,AGENCY_ID=$AGENCY_ID,GTFS_URL=$GTFS_URL,VEHICLE_POSITIONS_URL=$VEHICLE_POSITIONS_URL,PRESERVE_DB=$PRESERVE_DB,RMI_HOSTNAME=$RMI_HOSTNAME,DB_HOSTNAME=$DB_HOSTNAME,PRIMARY_AGENCY_HOST=$PRIMARY_AGENCY_HOST,PRIMARY_AGENCY_ID=$PRIMARY_AGENCY_ID
