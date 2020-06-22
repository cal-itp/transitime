#! /bin/sh

# setup-agency: this script does the database setup required for a public transit agency.
# Three arguments are required:
# - agency-id: a name for the agency, e.g. 'monterey' or 'riverside'
# - gtfs-url: static gtfs feed for the agency, e.g. http://www.mst.org/google/google_transit.zip
# - vehicle-positions-url: gtfs-rt feed for vehicle position updates, e.g. http://206.128.158.191/TMGTFSRealTimeWebService/Vehicle/VehiclePositions.pb
# IMPORTANT: any previously existing setup for an agency with the same ID will be clobbered

if [ "$#" -ne 3 ]; then
  echo "Usage: setup-agency <agency-id> <gtfs-url> <vehicle-positions-url>" >&2
  exit 1
fi

AGENCY_ID=$1
GTFS_URL=$2
VEHICLE_URL=$3

echo AGENCY_ID=$AGENCY_ID
echo GTFS_URL=$GTFS_URL
echo VEHICLE_URL=$VEHICLE_URL
echo

PROPFILE=${AGENCY_ID}.properties
DBNAME=agency-$AGENCY_ID

rm -f $PROPFILE
touch $PROPFILE

echo transitclock.core.agencyId=$AGENCY_ID >> $PROPFILE
echo transitclock.db.dbUserName=wildcard >> $PROPFILE
echo transitclock.db.dbPassword= >> $PROPFILE
echo transitclock.db.dbName=$DBNAME >> $PROPFILE
echo transitclock.db.dbHost=127.0.0.1 >> $PROPFILE
echo transitclock.db.dbType=postgresql >> $PROPFILE
echo transitclock.avl.gtfsRealtimeFeedURI=$VEHICLE_URL >> $PROPFILE
echo transitclock.hibernate.connection.url=jdbc:postgresql://127.0.0.1:5432/$DBNAME >> $PROPFILE
echo transitclock.hibernate.configFile=hibernate.cfg.xml >> $PROPFILE
echo transitclock.modules.optionalModulesList=org.transitclock.avl.GtfsRealtimeModule >> $PROPFILE
echo transitclock.web.mapTileUrl=https://tile.openstreetmap.org/{z}/{x}/{y}.png >> $PROPFILE
echo transitclock.web.mapTileCopyright=OpenStreetMap >> $PROPFILE
echo transitclock.rmi.secondaryRmiPort=0 >> $PROPFILE

dropdb $DBNAME
createdb $DBNAME || exit 0

psql -d $DBNAME -f transitclock/src/main/resources/ddl_postgres_org_transitime_db_structs.sql || exit 0
psql -d $DBNAME -f transitclock/src/main/resources/ddl_postgres_org_transitime_db_webstructs.sql || exit 0

psql -P pager=off -q -d $DBNAME --command=\\dt

java \
  -Dtransitclock.logging.dir=logs \
  -cp transitclock/target/Core.jar org.transitclock.applications.GtfsFileProcessor \
  -c "$AGENCY_ID.properties" \
  -storeNewRevs \
  -skipDeleteRevs \
  -gtfsUrl $GTFS_URL \
  -maxTravelTimeSegmentLength 100 || exit 0

java \
  -cp transitclock/target/Core.jar org.transitclock.applications.CreateAPIKey \
  -c "$AGENCY_ID.properties" \
  -n "Buzz Killington" \
  -u "https://www.google.com" \
  -e "info@example.com" \
  -p "4155550123" \
  -d "Core access application" || exit 0

CMD="psql -q -d agency-halifax --command=\"delete from webagencies where agencyid='"
CMD+="$AGENCY_ID';\""
eval $CMD

java \
  -Dhibernate.connection.url=jdbc:postgresql://127.0.0.1:5432/agency-halifax \
  -Dhibernate.connection.username=wildcard \
  -Dhibernate.connection.password= \
  -Dtransitclock.hibernate.configFile=hibernate.cfg.xml \
  -cp transitclock/target/Core.jar org.transitclock.db.webstructs.WebAgency \
  $AGENCY_ID \
  127.0.0.1 \
  $DBNAME \
  postgresql \
  0.0.0.0 \
  wildcard \
  "" || exit 0


