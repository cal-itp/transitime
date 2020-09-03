#! /bin/sh

# IMPORTANT: any previously existing setup for an agency with the same ID will be clobbered

if [ "$#" -ne 6 ]; then
  echo "Usage: setup-agency <agency-id> <gtfs-url> <vehicle-positions-url> <db-hostname> <primary-agency-db-hostname> <primary-agency-id>" >&2
  exit 1
fi

echo setting up agency $1...

AGENCY_ID=$1
GTFS_URL=$2
VEHICLE_POSITION__URL=$3
DBNAME="agency-$AGENCY_ID"
DB_HOSTNAME=$4
DB_PORT=5432
PRIMARY_AGENCY_DB_HOSTNAME=$5
PRIMARY_AGENCY_DB_PORT=5432
PRIMARY_AGENCY_ID=$6

if which ipconfig
then
  NUMERIC_IP=`ipconfig getifaddr en0`
else
  NUMERIC_IP=`curl ifconfig.me`
fi

echo AGENCY_ID: $AGENCY_ID
echo GTFS_URL: $GTFS_URL
echo DBNAME: $DBNAME
echo DB_HOSTNAME: $DB_HOSTNAME
echo DB_PORT: $DB_PORT
echo PRIMARY_AGENCY_DB_HOSTNAME: $PRIMARY_AGENCY_DB_HOSTNAME
echo PRIMARY_AGENCY_DB_PORT: $PRIMARY_AGENCY_DB_PORT
echo PRIMARY_AGENCY_ID: $PRIMARY_AGENCY_ID
echo NUMERIC_IP: $NUMERIC_IP

create-prop-file.sh $AGENCY_ID $GTFS_URL $VEHICLE_POSITION__URL $DB_HOSTNAME $DB_PORT || exit 0

dropdb -h $DB_HOSTNAME -p $DB_PORT -U postgres --if-exists $DBNAME
createdb -h $DB_HOSTNAME -p $DB_PORT -U postgres $DBNAME || exit 0

psql -h $DB_HOSTNAME -p $DB_PORT -U postgres -d $DBNAME -f /usr/local/transitclock/db/ddl_postgres_org_transitime_db_structs.sql || exit 0
psql -h $DB_HOSTNAME -p $DB_PORT -U postgres -d $DBNAME -f /usr/local/transitclock/db/ddl_postgres_org_transitime_db_webstructs.sql || exit 0

psql -h $DB_HOSTNAME -p $DB_PORT -U postgres -P pager=off -q -d $DBNAME --command=\\dt

java \
  -Dtransitclock.logging.dir=logs \
  -cp /usr/local/transitclock/lib/Core.jar org.transitclock.applications.GtfsFileProcessor \
  -c "/usr/local/transitclock/config/$AGENCY_ID.properties" \
  -storeNewRevs \
  -skipDeleteRevs \
  -gtfsUrl $GTFS_URL \
  -maxDistanceBetweenStops 150000 \
  -maxTravelTimeSegmentLength 100 || exit 0

java \
  -cp /usr/local/transitclock/lib/Core.jar org.transitclock.applications.CreateAPIKey \
  -c "/usr/local/transitclock/config/$AGENCY_ID.properties" \
  -n "Buzz Killington" \
  -u "https://www.google.com" \
  -e "info@example.com" \
  -p "4155550123" \
  -d "Core access application" || exit 0

CMD="psql -h $DB_HOSTNAME -p $DB_PORT -U postgres -q -d agency-$PRIMARY_AGENCY_ID --command=\"delete from webagencies where agencyid='"
CMD="$CMD$AGENCY_ID';\""
eval $CMD

java \
  -Dhibernate.connection.url=jdbc:postgresql://$PRIMARY_AGENCY_DB_HOSTNAME:$PRIMARY_AGENCY_DB_PORT/agency-$PRIMARY_AGENCY_ID \
  -Dhibernate.connection.username=postgres \
  -Dhibernate.connection.password=$PGPASSWORD \
  -Dtransitclock.hibernate.configFile=/usr/local/transitclock/config/hibernate.cfg.xml \
  -cp /usr/local/transitclock/lib/Core.jar org.transitclock.db.webstructs.WebAgency \
  $AGENCY_ID \
  $NUMERIC_IP \
  $DBNAME \
  postgresql \
  $PRIMARY_AGENCY_DB_HOSTNAME \
  postgres \
  "" || exit 0


