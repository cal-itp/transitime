#! /bin/sh

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 1
fi

docker run \
  --name transitclock-core-monterey \
  --rm \
  -e PGPASSWORD=$PGPASSWORD \
  -e AGENCY_ID="monterey" \
  -e GTFS_URL="http://www.mst.org/google/google_transit.zip" \
  -e VEHICLE_POSITIONS_URL="http://206.128.158.191/TMGTFSRealTimeWebService/Vehicle/VehiclePositions.pb" \
  -e PRESERVE_DB="1" \
  -e RMI_HOSTNAME="172.17.0.2" \
  -e DB_HOSTNAME="172.17.0.5" \
  -e PRIMARY_AGENCY_HOST="172.17.0.3" \
  -e PRIMARY_AGENCY_ID="halifax" \
  transitclock-core
