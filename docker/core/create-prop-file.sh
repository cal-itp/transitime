#/bin/sh

if [ "$#" -ne 5 ]; then
    echo "***"
    echo "*** usage: create-prop-file.sh <agency-id> <gtfs-url> <vehicle-positions-url> <db-hostname> <db-port>"
    echo "***"
    exit 1
fi

AGENCY_ID=$1
GTFS_URL=$2
VEHICLE_URL=$3
DB_HOSTNAME=$4
DB_PORT=$5

echo creating prop file...

echo AGENCY_ID=$AGENCY_ID
echo GTFS_URL=$GTFS_URL
echo VEHICLE_URL=$VEHICLE_URL
echo DB_HOSTNAME=$DB_HOSTNAME
echo DB_PORT=$DB_PORT
echo

PROPFILE=/usr/local/transitclock/config/transitclock.properties
DBNAME=agency-$AGENCY_ID

rm -f $PROPFILE
touch $PROPFILE

echo transitclock.core.agencyId=$AGENCY_ID >> $PROPFILE
echo transitclock.db.dbUserName=postgres >> $PROPFILE
echo transitclock.db.dbPassword=$PGPASSWORD >> $PROPFILE
echo transitclock.db.dbName=$DBNAME >> $PROPFILE
echo transitclock.db.dbHost=$DB_HOSTNAME >> $PROPFILE
echo transitclock.db.dbType=postgresql >> $PROPFILE
echo transitclock.avl.gtfsRealtimeFeedURI=$VEHICLE_URL >> $PROPFILE
echo transitclock.hibernate.connection.url=jdbc:postgresql://$DB_HOSTNAME:$DB_PORT/$DBNAME >> $PROPFILE
echo transitclock.hibernate.configFile=/usr/local/transitclock/config/hibernate.cfg.xml >> $PROPFILE
echo transitclock.modules.optionalModulesList=org.transitclock.avl.GtfsRealtimeModule >> $PROPFILE
echo transitclock.web.mapTileUrl=https://tile.openstreetmap.org/{z}/{x}/{y}.png >> $PROPFILE
echo transitclock.web.mapTileCopyright=OpenStreetMap >> $PROPFILE
echo transitclock.rmi.secondaryRmiPort=0 >> $PROPFILE
