#! /bin/sh

if [ -z "$PGPASSWORD" ]; then
    echo "env variable PGPASSWORD needs to be set to postgres password"
    exit 1
fi

docker run \
  --name transitclock-server-instance \
  --rm \
  -p 8080:8080 \
  -e PGPASSWORD=$PGPASSWORD \
  -e PRIMARY_AGENCY_ID="halifax" \
  -e GTFS_URL="http://gtfs.halifax.ca/static/google_transit.zip" \
  -e VEHICLE_POSITIONS_URL="http://gtfs.halifax.ca/realtime/Vehicle/VehiclePositions.pb" \
  -e RMI_HOSTNAME="172.17.0.2" \
  -e DB_HOSTNAME="172.17.0.3" \
  transitclock-server
