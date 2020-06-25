#! /bin/sh

# setup-agency: this script does the database setup required for a public transit agency.
# Three arguments are required:
# - agency-id: a name for the agency, e.g. 'monterey' or 'riverside'
# - gtfs-url: static gtfs feed for the agency, e.g. http://www.mst.org/google/google_transit.zip
# - vehicle-positions-url: gtfs-rt feed for vehicle position updates, e.g. http://206.128.158.191/TMGTFSRealTimeWebService/Vehicle/VehiclePositions.pb
# - output-file: where the output file is written. Default is <agency-id>.properties
# IMPORTANT: any previously existing setup for an agency with the same ID will be clobbered
export PGPASSWORD=transitclock

fail() {
  echo "*** $1" 1>&2
  exit 0
}

if [ "$#" -lt 3 ]; then
  echo "Usage: setup-agency <agency-id> <gtfs-url> <vehicle-positions-url> [<output-file>]" >&2
  exit 1
fi

AGENCY_ID=$1
GTFS_URL=$2
VEHICLE_URL=$3

echo AGENCY_ID=$AGENCY_ID
echo GTFS_URL=$GTFS_URL
echo VEHICLE_URL=$VEHICLE_URL

if [ ! -z "$4" ]; then
  PROPFILE=$4
else
  PROPFILE=${AGENCY_ID}.properties
fi

echo PROPFILE=$PROPFILE
echo

DBNAME=agency-$AGENCY_ID

echo "bar" > /usr/local/transitclock/config/foo.txt

rm -f $PROPFILE
touch $PROPFILE

echo transitclock.core.agencyId=$AGENCY_ID >> $PROPFILE
echo transitclock.db.dbUserName=postgres >> $PROPFILE
echo transitclock.db.dbPassword=$PGPASSWORD >> $PROPFILE
echo transitclock.db.dbName=$DBNAME >> $PROPFILE
echo transitclock.db.dbHost=$POSTGRES_PORT_5432_TCP_ADDR >> $PROPFILE
echo transitclock.db.dbType=postgresql >> $PROPFILE
echo transitclock.avl.gtfsRealtimeFeedURI=$VEHICLE_URL >> $PROPFILE
echo transitclock.hibernate.connection.url=jdbc:postgresql://${POSTGRES_PORT_5432_TCP_ADDR}:${POSTGRES_PORT_5432_TCP_PORT}/$DBNAME >> $PROPFILE
echo transitclock.hibernate.configFile=/usr/local/transitclock/config/hibernate.cfg.xml >> $PROPFILE
echo transitclock.modules.optionalModulesList=org.transitclock.avl.GtfsRealtimeModule >> $PROPFILE
echo transitclock.web.mapTileUrl=https://tile.openstreetmap.org/{z}/{x}/{y}.png >> $PROPFILE
echo transitclock.web.mapTileCopyright=OpenStreetMap >> $PROPFILE
echo transitclock.rmi.secondaryRmiPort=0 >> $PROPFILE

dropdb --if-exists -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres $DBNAME
createdb -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres $DBNAME || fail "could not create DB"

psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres -d $DBNAME -f /usr/local/transitclock/db/ddl_postgres_org_transitime_db_structs.sql || fail "running db_structs.sql failed"
psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres -d $DBNAME -f /usr/local/transitclock/db/ddl_postgres_org_transitime_db_webstructs.sql || fail "running db_webstructs.sql failed"

psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres -P pager=off -q -d $DBNAME --command=\\dt

java \
  -Dtransitclock.logging.dir=/usr/local/transitclock/logs \
  -cp /usr/local/transitclock/lib/Core.jar org.transitclock.applications.GtfsFileProcessor \
  -c $PROPFILE \
  -storeNewRevs \
  -skipDeleteRevs \
  -gtfsUrl $GTFS_URL \
  -maxTravelTimeSegmentLength 100 || fail "could not process static gtfs data"

java \
  -cp /usr/local/transitclock/lib/Core.jar org.transitclock.applications.CreateAPIKey \
  -c $PROPFILE \
  -n "Buzz Killington" \
  -u "https://www.google.com" \
  -e "info@example.com" \
  -p "4155550123" \
  -d "Core access application" || fail "could not create API key"

CMD="psql -h $POSTGRES_PORT_5432_TCP_ADDR -p $POSTGRES_PORT_5432_TCP_PORT -U postgres -q -d agency-halifax --command=\"delete from webagencies where agencyid='"
CMD="${CMD}$AGENCY_ID';\""
eval $CMD

# args for WebAgency (in order):
# - agency ID (e.g. 'monterey')
# - hostname (e.g. '127.0.0.1')
# - dbname (e.g. 'agency-monterey')
# - dbtype (e.g. 'postgresql')
# - dbhost (e.g. ${POSTGRES_PORT_5432_TCP_ADDR})
# - dbuser (e.g. 'root')
# - dbpass (e.g. 'biteme')

java \
  -Dhibernate.connection.url=jdbc:postgresql://${POSTGRES_PORT_5432_TCP_ADDR}:${POSTGRES_PORT_5432_TCP_PORT}/agency-halifax \
  -Dhibernate.connection.username=postgres \
  -Dhibernate.connection.password=$PGPASSWORD \
  -Dtransitclock.hibernate.configFile=/usr/local/transitclock/config/hibernate.cfg.xml \
  -cp /usr/local/transitclock/lib/Core.jar org.transitclock.db.webstructs.WebAgency \
  $AGENCY_ID \
  127.0.0.1 \
  $DBNAME \
  postgresql \
  $POSTGRES_PORT_5432_TCP_ADDR \
  postgres \
  $PGPASSWORD || fail "could not create web agency"

echo "baz" >> /usr/local/transitclock/config/foo.txt



