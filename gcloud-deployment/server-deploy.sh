#! /bin/sh

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 0
fi

if [ "$PGPASSWORD" == "transitclock" ]; then
    echo "PGPASSWORD needs to be set to super-secret external postgres password"
    exit 0
fi

PRIMARY_AGENCY_ID="halifax"
GTFS_URL="http://gtfs.halifax.ca/static/google_transit.zip"
VEHICLE_POSITIONS_URL="http://gtfs.halifax.ca/realtime/Vehicle/VehiclePositions.pb"
RMI_HOSTNAME="34.94.24.132"
DB_HOSTNAME="34.94.231.127"

gcloud compute instances create-with-container transitclock-server \
  --container-stdin --container-tty \
  --container-image gcr.io/transitclock-282522/server \
  --boot-disk-size=10GB \
  --tags transitclock-server \
  --container-env PGPASSWORD=$PGPASSWORD,GTFS_URL=$GTFS_URL,VEHICLE_POSITIONS_URL=$VEHICLE_POSITIONS_URL,RMI_HOSTNAME=$RMI_HOSTNAME,DB_HOSTNAME=$DB_HOSTNAME,PRIMARY_AGENCY_ID=$PRIMARY_AGENCY_ID
