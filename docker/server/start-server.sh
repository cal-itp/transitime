#!/usr/bin/env bash

if [ "$#" -ne 5 ]; then
  echo "Usage: go.sh <agency-id> <gtfs-url> <vehicle-positions-url> <rmi-hostname> <db-hostname>" >&2
  exit 1
fi

AGENCY_ID=$1
GTFS_URL=$2
VEHICLE_POSITIONS_URL=$3
RMI_HOSTNAME=$4
DB_HOSTNAME=$5

# usage: create-prop-file.sh <agency-id> <gtfs-url> <vehicle-positions-url> <db-hostname> <db-port>"
create-prop-file.sh $AGENCY_ID $GTFS_URL $VEHICLE_POSITIONS_URL $DB_HOSTNAME 5432

echo 'starting server...'

export JAVA_OPTS="-Dtransitclock.apikey=bfd3d506 \
  -Dtransitclock.logging.dir=/usr/local/transitclock/logs \
  -Dtransitclock.configFiles=/usr/local/transitclock/config/transitclock.properties"

echo JAVA_OPTS $JAVA_OPTS

/usr/local/tomcat/bin/startup.sh

echo 'started server'

tail -f /dev/null
